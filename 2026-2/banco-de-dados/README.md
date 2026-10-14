# Banco de Dados I — Projeto Integrador II

Professor: Prof. Luiz Fernando de Oliveira Silva.

Sistema Web para Gestão de Pesquisas por Questionários. O administrador elabora pesquisas e controla o acesso; participantes recebem senhas e tokens individuais; resultados agregados são encaminhados aos proprietários. Esta entrega contém os artefatos de banco e uma função de finalização, sem implementar o backend ou a entrega de resultados.

## Artefatos e análise inicial

```text
banco-de-dados/
├── README.md
├── modelo-conceitual.png
├── modelagem/
│   ├── mer.md
│   ├── gerar-diagrama.ps1
│   └── modelo-conceitual.svg
├── modelo-logico.md
├── schema.sql
├── queries.sql
└── testes/
    ├── integridade.sql
    ├── concorrencia.ps1
    ├── resultados.md
    ├── execucao-sql.txt
    └── execucao-concorrencia.txt
```

Consulte [MER e cardinalidades](modelagem/mer.md), [DER PNG](modelo-conceitual.png) e [modelo lógico, 3FN e anonimato](modelo-logico.md). A análise inicial encontrou apenas READMEs no repositório, sem modelos ou scripts: as entregas estavam pendentes. Nenhum arquivo de outra disciplina foi alterado.

## Execução

Validado com PostgreSQL 18.6 e `psql` no PATH. Use banco **novo e descartável**, com permissão para criar tabelas, funções e gatilhos. Configure credenciais localmente (por exemplo, pgpass); não versione senhas. Os scripts não apagam tabelas nem são idempotentes. Não executar a carga fictícia em produção.

Na raiz do repositório, após criar banco vazio (`createdb -U seu_usuario pi_bd_teste`):

```powershell
psql -U seu_usuario -d pi_bd_teste -X -v ON_ERROR_STOP=1 -f 2026-2/banco-de-dados/schema.sql
psql -U seu_usuario -d pi_bd_teste -X -v ON_ERROR_STOP=1 -f 2026-2/banco-de-dados/queries.sql
psql -U seu_usuario -d pi_bd_teste -X -v ON_ERROR_STOP=1 -f 2026-2/banco-de-dados/testes/integridade.sql
powershell -NoProfile -ExecutionPolicy Bypass -File 2026-2/banco-de-dados/testes/concorrencia.ps1 -HostBanco localhost -Porta 5432 -Usuario seu_usuario -Banco pi_bd_teste
```

Interrompa se qualquer comando terminar com código diferente de zero. `integridade.sql` exige a carga inicial e desfaz suas mudanças com ROLLBACK. Concorrência adiciona uma participação/resposta definitiva: execute por último, uma vez por banco. O erro de uma das duas sessões é esperado e verificado pelo teste.

Para reproduzir o diagrama em Windows PowerShell com System.Drawing:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File 2026-2/banco-de-dados/modelagem/gerar-diagrama.ps1
```

O gerador usa UTF-8 com BOM por compatibilidade com PowerShell 5.1. Fonte e SVG são editáveis.

## Comparação com os checklists originais

Itens conferidos contra o corpo integral das issues. “Atendido” descreve os artefatos e testes entregues, sujeitos à avaliação acadêmica. O estado administrativo das issues deve ser consultado no GitHub; esta tabela registra a cobertura dos critérios.

| Issue | Requisito original | Situação e evidência |
| --- | --- | --- |
| [#4](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/4) | Identificar as entidades principais | Atendido: nove entidades no MER |
| #4 | Modelar PESQUISA | Atendido: MER e PNG |
| #4 | Modelar CATEGORIA | Atendido: MER e PNG |
| #4 | Modelar QUESTAO | Atendido: MER e PNG |
| #4 | Modelar OPCAO | Atendido: MER e PNG |
| #4 | Modelar RESPOSTA_ANONIMA | Atendido: MER e PNG |
| #4 | Definir os relacionamentos | Atendido: tabela de relacionamentos no MER |
| #4 | Definir cardinalidades 1:N e N:M | Atendido: MER; entidades associativas resolvem N:M |
| #4 | Exportar DER em PNG | Atendido: PNG 1900 × 1500 inspecionado |
| #4 | Adicionar modelo ao repositório | Atendido: PNG, SVG, fonte e MER |
| [#5](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/5) | Converter DER para modelo lógico | Atendido: modelo-logico.md |
| #5 | Definir tabelas | Atendido: nove relações |
| #5 | Definir chaves primárias | Atendido: nove PKs |
| #5 | Definir chaves estrangeiras | Atendido: DDL; referência contextual de item por gatilho documentada |
| #5 | Normalizar até 3FN | Atendido: justificativa no modelo lógico |
| #5 | Criar CREATE TABLE | Atendido: schema.sql |
| #5 | Criar restrições de integridade | Atendido: PK, FK, UNIQUE, NOT NULL, CHECK e gatilhos testados |
| #5 | Relacionamentos com FOREIGN KEY | Atendido: schema.sql |
| #5 | Testar script no SGBD | Atendido: PostgreSQL 18.6 e evidências |
| #5 | Disponibilizar schema.sql | Atendido: nesta branch |
| [#6](https://github.com/Fatec-Extensao/pi-ads-2026-1-schiazza/issues/6) | INSERTs fictícios | Atendido: queries.sql |
| #6 | Dados suficientes para relacionamentos | Atendido: duas pesquisas, três categorias e quatro questionários |
| #6 | Pelo menos três consultas JOIN | Atendido: quatro consultas com JOIN |
| #6 | COUNT analítico | Atendido: quatro consultas |
| #6 | GROUP BY analítico | Atendido: quatro consultas |
| #6 | Relatórios estatísticos por pesquisa | Atendido: pesquisa, categoria e alternativa |
| #6 | Testar todas as consultas | Atendido: saídas registradas e totais verificados |
| #6 | Disponibilizar queries.sql | Atendido: nesta branch |

## Pendências de decisão e integração

- Validade dos tokens e mecanismo de entrega de resultados: não definidos nem presumidos.
- Uma categoria por participação e questões fechadas, obrigatórias e de escolha única delimitam a versão acadêmica inicial, sem constituir regras definitivas do produto. Múltiplas categorias e outros tipos dependem de aprovação futura.
- Definir limiar de publicação para categorias pequenas, supressão complementar e retenção de logs/backups.
- Implementar no backend autenticação, autorização, geração/entrega de credenciais, congelamento do questionário e acesso exclusivo pelo fluxo transacional. A política de permissões do serviço está pendente.

Não há identificadores diretos nas respostas, mas categorias e metadados podem permitir identificação indireta. Os relatórios fictícios não devem servir como modelo de publicação de grupos pequenos. Veja os limites no modelo lógico.
