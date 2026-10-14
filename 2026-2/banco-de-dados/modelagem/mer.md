# Modelo conceitual — Gestão de Pesquisas por Questionários

O administrador cria pesquisas, questões e alternativas, controla convites e encaminha resultados ao proprietário responsável. Usuários recebem senhas geradas automaticamente e tokens individuais; apenas hashes são persistidos. Administrador e proprietário são papéis de USUARIO nos relacionamentos com PESQUISA, podendo coincidir. Autorização dos papéis é responsabilidade do backend.

| Entidade | Atributos conceituais |
| --- | --- |
| USUARIO | identificador, nome, email, hash da senha |
| PESQUISA | identificador, título |
| CATEGORIA | identificador local, nome |
| QUESTAO | identificador local, enunciado |
| OPCAO | identificador local, descrição |
| PARTICIPACAO | usuário, pesquisa, categoria atribuída, concluída |
| TOKEN_ACESSO | hash do token |
| RESPOSTA_ANONIMA | identificador aleatório |
| ITEM_RESPOSTA | questão respondida, opção selecionada |

| Relacionamento | Cardinalidades e justificativa |
| --- | --- |
| USUARIO administra / possui PESQUISA | Usuário 0:N pesquisas; pesquisa exatamente 1 administrador e 1 proprietário |
| PESQUISA contém CATEGORIA | Pesquisa 0:N categorias; categoria exatamente 1 pesquisa |
| CATEGORIA define QUESTAO | Categoria 0:N questões; questão exatamente 1 categoria |
| QUESTAO oferece OPCAO | Questão 0:N opções; opção exatamente 1 questão |
| USUARIO participa de PESQUISA | N:M resolvido por PARTICIPACAO; no máximo uma participação por par |
| CATEGORIA classifica PARTICIPACAO | Categoria 0:N participações; participação exatamente 1 categoria da pesquisa |
| PARTICIPACAO recebe TOKEN_ACESSO | Participação 0:1 token ativo; token exatamente 1 participação |
| CATEGORIA agrupa RESPOSTA_ANONIMA | Categoria 0:N respostas; resposta exatamente 1 categoria da pesquisa |
| RESPOSTA_ANONIMA contém ITEM_RESPOSTA | Resposta finalizada 1:N itens; item exatamente 1 resposta |
| OPCAO é selecionada em ITEM_RESPOSTA | Opção 0:N itens; item exatamente 1 opção de uma questão do contexto |

Zero questões/opções é permitido durante a elaboração. Antes da abertura, o backend valida que há questões e alternativas suficientes. Nesta proposta, um participante recebe uma categoria em cada pesquisa, as questões são fechadas e todas são obrigatórias, com escolha única. Outros tipos exigem evolução do modelo; esta é uma delimitação técnica para revisão, não um requisito extraído das issues.

Não existe relacionamento entre PARTICIPACAO/TOKEN_ACESSO/USUARIO e RESPOSTA_ANONIMA. A finalização consome o token, marca a participação e insere resposta e itens atomicamente, sem retornar o UUID da resposta. O vínculo por categoria exige mitigação de identificação indireta.

`gerar-diagrama.ps1` é a fonte editável e reproduz o PNG e o SVG. O SVG também pode ser editado em ferramenta vetorial. As caixas contêm atributos conceituais; chaves físicas e validações estão no modelo lógico.
