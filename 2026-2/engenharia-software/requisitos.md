# Levantamento de requisitos — Projeto Integrador II (2026-2)

Versão para revisão acadêmica, 14/10/2026. Sistema Web para Gestão de Pesquisas por Questionários, FATEC Lins. Entrega da [issue #2](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/2).

## Base, método e limites

Levantamento documental: README da raiz e das quatro disciplinas; corpo integral e comentários (inexistentes na consulta) das issues #2 e #3; [MER](../banco-de-dados/modelagem/mer.md), [modelo lógico](../banco-de-dados/modelo-logico.md), [DDL](../banco-de-dados/schema.sql), [consultas](../banco-de-dados/queries.sql) e [evidências](../banco-de-dados/testes/resultados.md) incorporados pelo [PR #15](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/pull/15), base `605e0e5`. Não houve entrevistas, homologação institucional ou medição de uso real. Os critérios abaixo permitem futura aceitação; não significam funcionalidades implementadas.

O escopo é especificar criação, aplicação e análise de pesquisas institucionais. O banco e sua função de finalização existem; interface, backend, autenticação, autorização, emissão de credenciais e entrega de resultados são comportamentos a implementar. Esta entrega é exclusivamente de Engenharia de Software.

Origem **D**: descrição do projeto/READMEs; **B**: contrato e limites do banco; **P**: proposta verificável de qualidade a validar com a instituição. Todos os RF são prioritários para o fluxo descrito, sem atribuir cronograma de implementação.

## Atores e conceitos

| Ator | Responsabilidade e fronteira |
| --- | --- |
| Administrador | Cria pesquisas, designa proprietário, define categorias, questões e alternativas, prepara acesso, acompanha participação agregada e encaminha resultados. Só atua nas pesquisas para as quais está autorizado. |
| Respondente | Usuário convidado, recebe credenciais e token individual, autentica-se e conclui uma participação por pesquisa. |
| Proprietário | Responsável pela pesquisa que recebe resultados agregados das pesquisas que possui. Não recebe votos individuais nem correspondência identidade–resposta. |

São papéis contextuais de Usuário, não três tipos exclusivos de pessoa. Administrador e proprietário podem coincidir. O banco não implementa um catálogo global de papéis. Banco, navegador e serviço são componentes internos, não atores de negócio. Questionário é o conjunto de questões da categoria em uma pesquisa, não uma décima tabela. RespostaAnônima representa um questionário concluído; ItemResposta representa uma alternativa escolhida.

## Requisitos funcionais e aceitação

| ID / origem | Comportamento requerido | Critério de aceitação futuro | Caso |
| --- | --- | --- | --- |
| RF01 D/B | Administrador cadastra pesquisa com título e proprietário. | Pesquisa tem título não vazio, exatamente um administrador e um proprietário existentes; acesso não autorizado é negado. | UC01 |
| RF02 D/B | Administrador define categorias da pesquisa. | Nome não vazio e único na pesquisa; categorias de pesquisas distintas não são confundidas. | UC02 |
| RF03 D/B | Administrador compõe questionário por categoria com questões e alternativas. | Enunciados/descrições não vazios; questão pertence à categoria e alternativa à questão; antes de disponibilizar há questões e opções suficientes e estrutura congelada pelo serviço. Quantidade mínima de opções requer validação institucional. | UC03 |
| RF04 D/B | Administrador cadastra participação e providencia senha e token individuais. | Par usuário/pesquisa não se repete; uma categoria válida e no máximo um token ativo; senha e token em claro não são persistidos no banco. Entrega de credenciais terá mecanismo a definir. | UC04 |
| RF05 D/B | Sistema autentica respondente e valida seu acesso à pesquisa. | Credenciais inválidas, token alheio, inexistente ou consumido e participação concluída impedem envio; serviço confere associação usuário/token antes de chamar o banco. | UC05 |
| RF06 D/B | Respondente visualiza e preenche seu questionário. | Somente questões da categoria atribuída; uma opção por questão, todas obrigatórias nesta versão; revisão antes do envio; erro de validação preserva preenchimento na interface enquanto aberta. | UC06 |
| RF07 B | Sistema finaliza resposta, conclui participação e consome/desvincula token atomicamente. | Sucesso só após COMMIT; falha desfaz resposta, itens, conclusão e exclusão do token; duas submissões concorrentes produzem no máximo uma conclusão; confirmação não expõe UUID. | UC07 |
| RF08 D/B | Administrador acompanha participação agregada. | Exibe convidados e concluídos por pesquisa, sem relacionar identidade a escolhas; consultas preservam pesquisa sem respostas com total zero. | UC08 |
| RF09 D/B | Administrador gera relatório estatístico agregado. | Totais por pesquisa/categoria e distribuição por alternativa, incluindo zero votos; sem microdados ou identificadores de resposta; publicação depende das decisões de privacidade pendentes. | UC09 |
| RF10 D/B | Administrador encaminha e proprietário recebe resultados agregados autorizados. | Destinatário corresponde ao proprietário da pesquisa; acesso de outro proprietário é negado. Canal e política de divulgação precisam ser definidos antes de aceitação operacional. | UC10 |

## Requisitos não funcionais

| ID / origem | Restrição ou qualidade e verificação |
| --- | --- |
| RNF01 B | Anonimato estrutural: respostas/itens sem usuário, participação, token, IP ou horário e sem tabela de correspondência; UUID aleatório. Inspecionar esquema e saída do serviço; não guardar UUID junto à identidade em logs. Não equivale a anonimato absoluto: categoria, observação da transação, WAL e backups podem permitir correlação. |
| RNF02 B | Integridade: finalização indivisível, participação única e serialização do token. Reproduzir testes de rollback, reuso e concorrência do banco e, futuramente, testes de integração do serviço. Cliente não tem escrita SQL direta. |
| RNF03 B | Segurança de acesso: serviço confiável autentica e autoriza cada operação; hashes de senha adequados, tokens de alta entropia e hash SHA-256, transporte protegido e nenhuma credencial de banco no navegador. Testar credenciais inválidas, troca de identidade, papel e pesquisa. A função SECURITY INVOKER não substitui permissões; política de roles/GRANT ainda não implementada. |
| RNF04 P | Tempo de resposta: medir p95 de abertura do questionário, submissão e consulta agregada separadamente, com volume, concorrência, rede e equipamento registrados. Meta numérica e carga precisam de validação institucional; não há SLA nem medição atual. Aceitação de desempenho permanece pendente até acordar e atingir esses valores. |
| RNF05 D/P | Responsividade: proposta de aceite em larguras de 360, 768 e 1280 px, sem rolagem horizontal do formulário, com controles e mensagens utilizáveis. Verificar no futuro protótipo; larguras são proposta técnica, não decisão institucional. |
| RNF06 P | Usabilidade/acessibilidade: rótulos associados aos campos, navegação por teclado, foco visível e erros em texto associados à questão. Testar preenchimento e correção de erro sem mouse; revisão humana de contraste e leitura. Não declarar certificação de acessibilidade. |
| RNF07 B/P | Recuperação: em falha não confirmar conclusão; permitir nova tentativa se token ainda ativo. Se conexão cair após COMMIT, consultar estado da participação autenticada e informar conclusão sem repetir gravação ou revelar resposta. Testar quedas antes e depois de commit no futuro serviço. |
| RNF08 B | Privacidade operacional: restringir operadores, redigir tokens/payloads em logs e proteger backups; retenção, limiares e supressão ainda a definir. Revisar configuração e impedir divulgação real enquanto essas políticas não forem aprovadas. |
| RNF09 P | Manutenibilidade: manter IDs de requisitos, rastreabilidade, fontes UML e exportações sincronizadas; reproduzir diagramas e verificar links a cada mudança de contrato. |

## Regras de negócio e delimitações

| ID | Regra |
| --- | --- |
| RN01 | Cada pesquisa tem exatamente um administrador e um proprietário; um usuário pode exercer ambos os papéis e administrar/possuir várias pesquisas. |
| RN02 | Há no máximo uma participação por usuário por pesquisa, independentemente da categoria; o mesmo usuário pode responder outras pesquisas. |
| RN03 | Cada participação recebe uma categoria daquela pesquisa. Categoria única é delimitação acadêmica inicial, sujeita à evolução aprovada. |
| RN04 | Questões fechadas, obrigatórias, de escolha única delimitam a versão. Não se presumem questões abertas, opcionais ou múltipla escolha. |
| RN05 | Token ativo pertence a uma participação; no máximo um por participação; participação concluída não recebe novo token e não pode ser reaberta, alterada ou excluída pelo fluxo atual. |
| RN06 | Conclusão grava uma resposta e todos os itens, marca participação e exclui o registro do token na mesma transação. Nenhum UUID da resposta é retornado; não há ligação identidade–resposta persistida. |
| RN07 | Cada item seleciona uma alternativa da questão e do contexto pesquisa/categoria da resposta; questões repetidas ou ausentes invalidam o envio completo. |
| RN08 | Serviço deve validar prontidão e congelar questionário ao disponibilizá-lo. DDL não modela estado aberto/fechado e não impede toda inserção/edição estrutural; não atribuir tal garantia ao banco. Opções e respostas já têm gatilhos de imutabilidade. |
| RN09 | Resultados destinados ao proprietário são agregados; análise interna fictícia do banco não autoriza divulgação real de grupos pequenos. |

## Especificações de casos de uso

Todos os casos descrevem comportamento esperado. Erro de autorização encerra a operação sem efeito. “Disponível” é condição do serviço proposto, não coluna existente no DDL.

| Caso / ator / objetivo | Pré-condição e fluxo principal | Alternativas e pós-condição |
| --- | --- | --- |
| UC01 Administrador — criar pesquisa | Administrador autenticado/autorizado; informa título e proprietário; sistema valida e cadastra pesquisa associada ao administrador. | Dados vazios ou usuário inexistente: corrigir sem salvar; sucesso cria pesquisa em elaboração, sem presumir estado persistido. |
| UC02 Administrador — definir categorias | Pesquisa em elaboração sob sua gestão; informa nomes; sistema valida e associa categorias à pesquisa. | Nome repetido na pesquisa/vazio: rejeitar; sucesso cria categorias sem afetar outras pesquisas. |
| UC03 Administrador — compor questionário | Categoria válida de pesquisa em elaboração; cadastra questões e alternativas; revisa conteúdo. | Dados inválidos: corrigir; antes da abertura serviço verifica prontidão e congela estrutura. Edição publicada requer evolução própria. |
| UC04 Administrador — preparar acesso | Pesquisa pronta e usuário existente/cadastrado de modo autorizado; escolhe categoria; sistema cria participação e gera credenciais/token seguros, disponibilizando-os por mecanismo a definir. | Participação repetida ou concluída: não duplicar/não emitir; falha de entrega não implica conclusão. Reemissão e recuperação de credenciais exigem desenho futuro. |
| UC05 Respondente — autenticar e validar acesso | Possui credenciais e token; informa acesso; serviço autentica, verifica vínculo e participação; autoriza questionário da categoria. | Falha: negar acesso sem revelar vínculo ou escolhas de terceiros. Sucesso estabelece contexto autorizado; autenticação não consome token. |
| UC06 Respondente — preencher questionário | Inclui UC05; sistema apresenta questões da categoria; respondente escolhe alternativas e revisa. | Omissão ou saída antes do envio: não há conclusão nem consumo; rascunho persistente não foi especificado. Sucesso deixa conjunto pronto para UC07, sem gravar resposta definitiva. |
| UC07 Respondente — concluir questionário | Inclui UC05; questões preenchidas; serviço valida formato/contexto, inicia transação e chama finalizar_questionario; banco bloqueia token e participação, valida completude, grava resposta e itens, conclui participação, exclui token; serviço confirma COMMIT e informa sucesso. | Incompleto, alternativa incompatível ou questão repetida: ROLLBACK, sem efeitos parciais. Token consumido/inválido ou concorrência perdedora: rejeitar. Falha após commit: recuperar estado conforme RNF07. Sucesso deixa participação concluída sem vínculo à resposta. |
| UC08 Administrador — acompanhar participação | Autorizado na pesquisa; solicita contagens; sistema calcula convidados/concluídos e apresenta totais. | Sem participações: zero; acesso negado: sem relatório. Não revela opções individuais. |
| UC09 Administrador — gerar relatório | Autorizado; solicita estatísticas; sistema agrega por pesquisa, categoria, questão e opção. | Sem votos: zeros; política de publicação não definida: manter análise restrita, sem tratar exercício fictício como divulgação aprovada. Sucesso produz relatório agregado. |
| UC10 Administrador e Proprietário — encaminhar/receber resultados | Inclui UC09; proprietário e autorização verificados; política de divulgação aprovada; administrador encaminha e proprietário recebe agregados pelo canal que vier a ser definido. | Canal/políticas indefinidos bloqueiam operação real; falha de entrega não altera respostas. Não se presume email, PDF, download ou painel como decisão. |

UC06 e UC07 incluem UC05 porque ambos exigem acesso validado, inclusive em nova submissão. UC07 é um objetivo separado após preenchimento; não há `extend` usado como simples indicação de ordem. UC10 inclui UC09 para obter os agregados. Demais pré-condições de autenticação administrativa não são representadas como casos de uso independentes.

![Diagrama UML de casos de uso](modelagem-uml/casos-de-uso/casos-de-uso.svg)

[Fonte PlantUML editável](modelagem-uml/casos-de-uso/casos-de-uso.puml). [Classes, sequência e rastreabilidade](modelagem-uml/README.md).

## Decisões abertas e validação institucional

| Pendência | Consequência / validação necessária |
| --- | --- |
| Validade dos tokens | Não adicionar expiração fictícia; definir prazo, revogação e recuperação com responsável institucional antes da implementação. |
| Canal de entrega | Definir como credenciais e resultados chegam aos destinatários e como se confirma autorização/recebimento; nenhum canal escolhido. |
| Grupos pequenos | Definir limiar, supressão complementar e atualização dos relatórios antes de publicar agregados reais. |
| Retenção de metadados | Definir prazos e acesso a logs, WAL e backups; avaliar correlação por operadores privilegiados. |
| Metas de qualidade | Homologar carga e p95, disponibilidade e critérios de interface; não apresentar propostas como decisões já tomadas. |

Evidências do PR #15 são testes do banco, não testes destes futuros fluxos web. A documentação cobre os cinco itens da issue #2 (RF, RNF, UML, SVG e incorporação do diagrama); conclusão administrativa depende de revisão.
