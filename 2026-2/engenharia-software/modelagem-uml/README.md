# Modelagem UML — Projeto Integrador II (2026-2)

Entrega para revisão da [issue #3](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/3), alinhada aos [requisitos](../requisitos.md) e ao contrato de Banco de Dados da main `605e0e5` (PR #15). Fontes PlantUML em UTF-8 e exportações SVG editáveis, incorporadas abaixo. Modelos conceituais e interações futuras não constituem implementação do backend.

## Artefatos

| Diagrama | Fonte | Exportação |
| --- | --- | --- |
| Casos de uso (#2) | [PlantUML](casos-de-uso/casos-de-uso.puml) | [SVG](casos-de-uso/casos-de-uso.svg) |
| Classes (#3) | [PlantUML](classes/classes.puml) | [SVG](classes/classes.svg) |
| Sequência (#3) | [PlantUML](sequencia/responder-questionario.puml) | [SVG](sequencia/responder-questionario.svg) |

## Estrutura e mapeamento

![Classes conceituais](classes/classes.svg)

Associações simples UML evitam presumir exclusão em cascata ou ciclo de vida de composição: o DDL usa NO ACTION. Multiplicidade junto à ponta indica quantos objetos daquela classe correspondem a um objeto da outra ponta. Administrador/proprietário são papéis de Usuário em Pesquisa, podendo coincidir; não se inventa herança nem tabela de papéis.

| Classe | Relação SQL / interpretação |
| --- | --- |
| Usuário | `usuario`: identidade, nome, email, senha_hash; não tem associação com respostas. |
| Pesquisa | `pesquisa`: título, administrador e proprietário; não há status/data de publicação no DDL. |
| Categoria | `categoria`: identidade local `(pesquisa_id,id)`, nome único por pesquisa. |
| Questão | `questao`: identidade local `(pesquisa_id,categoria_id,id)`; integra questionário da categoria. |
| Opção | `opcao`: identidade local composta até questão; descrição da alternativa. |
| Participação | `participacao`: associação materializada usuário/pesquisa, categoria e concluida; par usuário/pesquisa único. |
| TokenAcesso | `token_acesso`: hash e vínculo exclusivo com participação; somente tokens ativos persistem. |
| RespostaAnônima | `resposta_anonima`: UUID e contexto pesquisa/categoria, sem identidade; diagrama deriva pesquisa pela categoria para evitar associação conceitual redundante. |
| ItemResposta | `item_resposta`: questão e opção locais, única por resposta/questão; associação conceitual com Opção validada por `validar_item`, não por FK direta. |

Questionário, Relatório e os papéis de ator não acrescentam tabelas: questionário é conjunto de questões, relatório é projeção agregada das consultas. Operações de aplicação estão no diagrama de sequência; não foram inventados métodos persistidos nas entidades.

Pesquisa/categoria/questão admitem zero filhos na elaboração. Prontidão exige validação futura do serviço. A multiplicidade RespostaAnônima → ItemResposta é 1..* no agregado finalizado pelo fluxo autorizado: SQL privilegiado direto pode criar resposta vazia, e o DDL isolado não garante essa multiplicidade. Cada questão tem exatamente um item no agregado concluído; quantidade igual, unicidade e contexto asseguram cobertura completa na função. Participação concluída fica sem token e imutável; token excluído não elimina usuário ou participação.

## Comportamento principal e contrato técnico

![Sequência de preenchimento e conclusão](sequencia/responder-questionario.svg)

UC05–UC07 representam autenticação, carregamento por categoria, preenchimento, revisão e submissão. Interface e serviço são previstos. A função `finalizar_questionario(p_hash text, p_itens jsonb) RETURNS void` já existe. `p_itens` é array de objetos `{questao_id, opcao_id}`; IDs são locais ao contexto do token. Exemplo apenas estrutural: `[{"questao_id":1,"opcao_id":2}]` só é válido se o questionário contiver exatamente aquela questão e opção.

O serviço deverá autenticar e associar token ao usuário; a função não recebe identidade autenticada nem a valida por conta própria. Dentro da transação do chamador, bloqueia token e participação com FOR UPDATE, confere token/completude, cria UUID, insere itens, marca participação e exclui token. PK rejeita questão duplicada e gatilho valida alternativa no contexto. Qualquer exceção exige rollback pelo chamador; sucesso da função ainda não é sucesso durável sem commit. Não retornar nem registrar UUID com identidade. Revalidação e bloqueio no envio evitam depender da consulta inicial sujeita a concorrência.

Se dois envios concorrem pelo mesmo token, o bloqueio os serializa e apenas um finaliza. Se o vencedor sofrer rollback, outra tentativa pode ter sucesso; não se presume rejeição permanente antes de commit. Token ausente, consumo prévio, participação concluída, conteúdo incompleto e alternativa incompatível são falhas sem conclusão parcial. Queda após commit exige consulta de estado autenticado, não uma nova resposta. Trata-se de requisito do futuro serviço, ainda sem teste web.

A função é SECURITY INVOKER; restrições de escrita direta, roles e GRANT ainda precisam ser implementadas. Search_path fixo protege as funções contra tabelas temporárias homônimas, sem substituir autorização. Congelamento integral do questionário deve ser responsabilidade do serviço: o banco protege opções/respostas e participações concluídas, mas não modela todo o ciclo de publicação.

## Rastreabilidade

| Requisitos / regras | Casos / classes | Sequência / evidência existente |
| --- | --- | --- |
| RF01–03, RN01/RN08 | UC01–03; Usuário, Pesquisa, Categoria, Questão, Opção | Preparação fora do fluxo do respondente; DDL e MER; prontidão/congelamento a implementar. |
| RF04–05, RN02–05, RNF03 | UC04–05; Participação, TokenAcesso, Usuário | Autenticação/vínculo previstos; PK, UNIQUE e gatilhos de participação/token existentes. |
| RF06–07, RN06–07, RNF01–02/07 | UC06–07; RespostaAnônima, ItemResposta, Opção | Preenchimento e transação; testes do banco para completude, contexto, reuso, rollback e concorrência. |
| RF08–10, RN09/RNF08 | UC08–10; projeções de Pesquisa, Categoria e respostas | Quatro consultas agregadas existentes; autorização, divulgação e entrega pendentes. |
| RNF04–06/09 | Interface e documentação | Critérios futuros de desempenho/responsividade/acessibilidade; fontes e exports reproduzíveis nesta entrega. |

Anonimato é estrutural, não absoluto: categorias pequenas, logs, WAL, backups e operadores privilegiados podem correlacionar respostas. Validade de tokens, canal de entrega, limiar/supressão de grupos pequenos e retenção permanecem abertos em [requisitos](../requisitos.md). A atomicidade não remove observabilidade privilegiada.

## Reprodução e revisão

Com Java e PlantUML instalados, a partir da raiz:

```powershell
java -jar CAMINHO/plantuml.jar -charset UTF-8 -tsvg 2026-2/engenharia-software/modelagem-uml/casos-de-uso/casos-de-uso.puml 2026-2/engenharia-software/modelagem-uml/classes/classes.puml 2026-2/engenharia-software/modelagem-uml/sequencia/responder-questionario.puml
```

O mecanismo de layout do PlantUML pode exigir Graphviz. Não editar somente a exportação: alterar fonte, renderizar, conferir acentos, multiplicidades, setas e fragmentos alternativos. Veja [validação da entrega](validacao.md). A issue #3 é coberta pelas nove classes conceituais, classes Pesquisa/Questão/RespostaAnônima/Categoria explícitas, diagrama de classes, sequência com preenchimento e fontes/exportações/especificação neste diretório. As issues permanecem abertas para revisão.
