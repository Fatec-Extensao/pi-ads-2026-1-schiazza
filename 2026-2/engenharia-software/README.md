# Engenharia de Software II

**Disciplina:** Engenharia de Software II
**Professor:** Prof. Rafael Hamamura

## Objetivo

Este diretório concentra os artefatos relacionados à análise, especificação e modelagem do sistema desenvolvidos durante a disciplina de Engenharia de Software II.

A documentação armazenada nesta pasta tem como objetivo representar os requisitos, regras de negócio, comportamento e estrutura da aplicação, mantendo os modelos alinhados às necessidades identificadas no Projeto Integrador.

## Conteúdo Previsto

Este diretório poderá conter:

* levantamento de requisitos;
* requisitos funcionais;
* requisitos não funcionais;
* regras de negócio;
* especificação de casos de uso;
* diagramas UML;
* documentação técnica relacionada à arquitetura e modelagem do sistema.

## Estrutura

```text
engenharia-software/
├── requisitos.md
├── modelagem-uml/
│   ├── casos-de-uso/
│   ├── classes/
│   └── sequencia/
└── README.md
```

## Requisitos

O arquivo `requisitos.md` será utilizado para registrar e manter os requisitos identificados durante o desenvolvimento do projeto.

A documentação poderá ser organizada em:

### Requisitos Funcionais

Representam funcionalidades e comportamentos que o sistema deverá oferecer aos usuários.

Exemplos:

* gerenciamento de pesquisas;
* cadastro de questionários;
* gerenciamento das categorias de participantes;
* aplicação dos questionários;
* armazenamento das respostas;
* geração de relatórios.

### Requisitos Não Funcionais

Representam características de qualidade, restrições técnicas e requisitos relacionados à operação do sistema.

Podem envolver:

* segurança;
* desempenho;
* usabilidade;
* disponibilidade;
* privacidade;
* manutenibilidade.

## Modelagem UML

A pasta `modelagem-uml/` será utilizada para armazenar os diagramas produzidos durante a análise e modelagem do sistema.

Entre os artefatos previstos estão:

### Diagrama de Casos de Uso

Representa os atores envolvidos no sistema e as funcionalidades com as quais cada ator poderá interagir.

### Diagrama de Classes

Representa as principais entidades, atributos, operações e relacionamentos existentes no domínio da aplicação.

### Diagrama de Sequência

Representa a interação entre os componentes do sistema e a ordem das mensagens trocadas durante a execução de determinados processos.

Outros diagramas poderão ser adicionados conforme a evolução e as necessidades do projeto.

## Organização

Os artefatos desta pasta deverão permanecer consistentes com:

* os requisitos definidos para o sistema;
* a modelagem do banco de dados;
* as interfaces desenvolvidas;
* as regras de negócio;
* as decisões tomadas durante o desenvolvimento do Projeto Integrador.

Alterações significativas nos requisitos ou na estrutura do sistema deverão ser refletidas na documentação e nos respectivos diagramas.

## Entregas para revisão — issues #2 e #3

- [Levantamento de requisitos em Markdown](requisitos.md): atores, RF/RNF, regras, critérios de aceitação e casos de uso.
- [Modelagem UML e especificação técnica](modelagem-uml/README.md): fontes editáveis e SVG de casos de uso, classes e sequência, com visual próximo ao Astah.
- [Registro de validação e cobertura dos checklists](modelagem-uml/validacao.md).

Aparência semelhante ao Astah não implica arquivo nativo `.asta`: as fontes são PlantUML e as exportações são SVG. O backend é previsto; apenas os artefatos SQL do PR #15 já existem. As decisões abertas estão registradas no levantamento, sem presumir validade de token, canal de entrega, limiar de grupos pequenos ou retenção.
