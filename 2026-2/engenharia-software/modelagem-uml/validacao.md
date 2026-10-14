# Validação e cobertura — 14/10/2026

Base de leitura: main `605e0e5`, merge do PR #15. Lidos README da raiz e de cada disciplina, MER, modelo lógico, DDL, carga/consultas e registros/scripts de testes do banco. Issues #2 e #3 lidas integralmente, sem comentários na consulta. Nenhuma entrevista institucional ou implementação web foi presumida.

## Verificações desta entrega

- Três fontes PlantUML renderizadas em SVG pelo servidor PlantUML; sem erro de sintaxe. Conteúdo enviado para renderização é documentação do repositório público, sem dados reais ou credenciais.
- SVGs analisados como XML e convertidos temporariamente em imagens para inspeção visual; conferidos textos em português, setas, atores, multiplicidades e fragmentos de sequência. Fundo branco e caixas claras seguem aparência próxima ao Astah; não são arquivos nativos `.asta`.
- Validador local verifica presença dos três pares fonte/exportação, três atores, dez casos de uso, nove classes, dez RF, nove RNF, marcadores transacionais, ausência de associação direta identidade–resposta no modelo e links locais.
- Revisão semântica contra `schema.sql`: papéis por pesquisa, chaves locais, unicidade usuário/pesquisa, categoria única nesta versão, token 0..1, resposta sem identidade, validação contextual do item por gatilho e finalização na transação do chamador.
- Revisão dos caminhos/checklists originais e do escopo do diff: somente `2026-2/engenharia-software/`. Nenhuma alteração de main, Banco de Dados, Web ou Segurança.

Reprodução da validação local, a partir da raiz:

```powershell
node 2026-2/engenharia-software/modelagem-uml/validar.cjs
Get-ChildItem 2026-2/engenharia-software/modelagem-uml -Recurse -Filter *.svg | ForEach-Object { [xml](Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8) | Out-Null }
git diff --check
```

Resultado: validação documental e XML aprovadas; três diagramas renderizados e inspecionados. A renderização é necessária para validar a sintaxe UML: o validador local faz verificações documentais, não implementa um parser PlantUML nem prova correção de todo o modelo.

## Checklist original #2

| Item | Evidência |
| --- | --- |
| Mapear Requisitos Funcionais, como criar questionário, autenticar respondente e gerar relatório | `requisitos.md`, RF01–RF10 e UC01–UC10 |
| Mapear Requisitos Não-Funcionais, como anonimato, tempo de resposta e responsividade | RNF01–RNF09; metas ainda não homologadas explicitamente identificadas |
| Elaborar o Diagrama de Casos de Uso em UML | `casos-de-uso/casos-de-uso.puml`, três atores e dez UC |
| Salvar o diagrama em PNG ou SVG | `casos-de-uso/casos-de-uso.svg` |
| Anexar o diagrama à documentação | Imagem incorporada em `requisitos.md` e links no índice UML |

## Checklist original #3

| Item | Evidência |
| --- | --- |
| Modelar as classes conceituais do domínio | Nove classes, associações e multiplicidades em `classes/classes.puml` |
| Representar entidades como Pesquisa, Questão, Resposta e Categoria | Classes explícitas, com RespostaAnônima e ItemResposta distinguindo agregado e item |
| Elaborar o Diagrama de Classes | Fonte e `classes/classes.svg` |
| Elaborar o Diagrama de Sequência do fluxo principal | Fonte e `sequencia/responder-questionario.svg` |
| Representar o fluxo de um respondente preenchendo um questionário | UC05–UC07, loop de preenchimento, revisão e conclusão com alternativas |
| Salvar os diagramas no repositório | Três fontes e três SVG nos subdiretórios previstos |
| Adicionar a especificação técnica necessária | `README.md` desta pasta: mapeamento das classes, contrato da função, fronteiras e rastreabilidade |

Cobertura dos artefatos não equivale a aprovação institucional. Issues não fechadas nem checklists remotos alterados antes da revisão.

## Limites dos testes e decisões

Os testes PostgreSQL 18.6 registrados pelo PR #15 foram usados como evidência existente e **não foram reexecutados nesta entrega documental**. Autenticação, autorização, desempenho, responsividade, entrega e testes de integração do futuro serviço não foram implementados/executados. Não há garantia de anonimato absoluto contra correlação por grupos pequenos ou operadores privilegiados. Validade dos tokens, canal de entrega, supressão e retenção continuam pendentes.
