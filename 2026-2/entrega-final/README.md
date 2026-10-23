# Revisão da entrega — Projeto Integrador 2026-2

Registro de 23/10/2026. Escopo desta consolidação: Engenharia de Software, Banco de Dados, Desenvolvimento Web e apresentação documental. Os relatórios de Compliance e Segurança continuam pendentes exclusivamente nas issues #11 e #12.

## Conteúdo disponibilizado

- [Índice por issue e conteúdo integral dos artefatos](./conteudo-das-issues.md).
- [Apresentação em Markdown](./apresentacao.md).
- Fontes UML em PlantUML e SVG, DER PNG/SVG e quatro wireframes SVG.
- Scripts SQL DDL/DML, testes de integridade/concorrência e evidências anteriores.
- Doze páginas HTML, CSS, JavaScript e testes de interface reproduzíveis.

## Revisão interdisciplinar

| Pasta | Revisão nesta consolidação |
|---|---|
| Engenharia de Software | Requisitos, fontes UML, exportações e rastreabilidade conferidos pelo validador documental; nenhum backend foi presumido |
| Banco de Dados | MER/DER, modelo lógico, DDL, consultas e registros de testes conferidos quanto à presença e aos links; evidências PostgreSQL 18.6 preservadas, sem nova execução SQL nesta montagem |
| Desenvolvimento Web | Fontes, wireframes, navegação e evidências organizados; publicação nativa e testes no endereço público registrados nos arquivos da disciplina |
| Segurança | Pasta inspecionada: há orientações de README; faltam os dois relatórios específicos, acompanhados nas issues #11 e #12 |

A revisão da pasta Segurança registra a lacuna; não equivale a entregar seus documentos. As pendências não são ocultadas nem declaradas resolvidas pelo fechamento da tarefa de organização final.

## Material de apresentação

A apresentação é entregue em Markdown, com diagramas, explicações, roteiro de demonstração e limites do protótipo. Não há vídeo gravado: o item condicional de vídeo não se aplica a este pacote. Não foram adicionados arquivos DOCX, XLSX, PPTX ou PDF.

## Critérios de encerramento administrativo

As issues #2–#10 e #13 podem ser encerradas após integração desta consolidação e confirmação das verificações. As issues #11 e #12 devem continuar abertas. Encerramento técnico não constitui aceite do professor, conformidade jurídica nem afirmação de sistema pronto para produção.

## Reproduzir

Consulte as instruções de cada disciplina. O front-end pode ser aberto por desenvolvimento-web/src/index.html; os testes de navegador precisam de Playwright. SQL deve ser reproduzido apenas em banco novo e descartável, conforme o README de Banco de Dados. Não há credenciais de banco no front-end.
