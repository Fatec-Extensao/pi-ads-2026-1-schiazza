# Modelo relacional — PostgreSQL

PK = chave primária; FK = chave estrangeira. Atributos são NOT NULL, exceto onde indicado (não há atributos opcionais nesta versão).

| Relação | Chaves e atributos |
| --- | --- |
| usuario | **id** PK identity; nome, email UNIQUE, senha_hash |
| pesquisa | **id** PK identity; titulo; administrador_id e proprietario_id FK usuario |
| categoria | **(pesquisa_id, id)** PK; pesquisa_id FK pesquisa; nome; UNIQUE(pesquisa_id,nome) |
| questao | **(pesquisa_id, categoria_id, id)** PK; FK categoria(pesquisa_id,id); enunciado |
| opcao | **(pesquisa_id, categoria_id, questao_id, id)** PK; FK questao; descricao |
| participacao | **(pesquisa_id, usuario_id)** PK; usuario_id FK usuario; (pesquisa_id,categoria_id) FK categoria; concluida boolean |
| token_acesso | **token_hash** PK; (pesquisa_id,usuario_id) UNIQUE e FK participacao |
| resposta_anonima | **id** PK UUID aleatório; (pesquisa_id,categoria_id) FK categoria |
| item_resposta | **(resposta_id, questao_id)** PK; resposta_id FK resposta_anonima; opcao_id local |

IDs de categoria, questão e opção são locais ao respectivo pai, atribuídos pelo backend. Uma categoria pertence a uma pesquisa; questões de categorias diferentes são distintas, mesmo quando têm o mesmo enunciado. A função `validar_item` deriva pesquisa/categoria da resposta e valida a opção na chave completa com bloqueio de chave. Essa referência contextual é garantida por gatilho, e não por uma FK declarativa redundante. Opções e respostas são imutáveis por gatilho, impedindo que a referência validada seja posteriormente quebrada. FKs usam NO ACTION por padrão, sem exclusão em cascata.

## Normalização

1FN: atributos atômicos; alternativas e respostas não são listas nas tabelas. O JSON é somente um parâmetro de entrada, convertido em linhas.

2FN: atributos descritivos dependem da chave completa: nome da categoria depende da pesquisa e ID local; enunciado depende do contexto e ID da questão; descrição da opção depende de toda a chave da opção. Categoria e estado da participação dependem do par pesquisa/usuário. Opção selecionada depende da resposta e questão.

3FN: nome/email/hash ficam exclusivamente em usuario; título em pesquisa; descrições em suas entidades. No item, pesquisa e categoria não são repetidas: são determinadas por resposta_id. Isso evita a dependência transitiva resposta_id → contexto em uma tabela cuja chave é (resposta_id,questao_id). Os demais atributos não-chave não determinam outros atributos não-chave. Chaves alternativas de email, categoria/nome e token/participação têm unicidade explícita.

## Finalização e limites

Nesta versão acadêmica inicial, cada participação recebe exatamente uma categoria. Múltiplas categorias dependem de aprovação futura. As questões fechadas, obrigatórias e de escolha única são uma limitação da versão, não uma regra definitiva do produto.

`finalizar_questionario(hash, itens)` bloqueia token e participação; exige exatamente um item válido por questão; cria UUID aleatório; grava itens; marca participação concluída e exclui token. Tudo ocorre na transação do chamador: qualquer falha desfaz a chamada. PK dos itens rejeita questões repetidas; gatilho rejeita alternativas de contexto diferente; PK da participação impede inscrição repetida. O mesmo usuário pode participar de outras pesquisas. Participações concluídas não podem ser alteradas ou excluídas, nem receber novos tokens.

O backend deve autenticar o usuário e associá-lo ao token antes da chamada, gerar senhas fortes e tokens criptograficamente aleatórios, armazenar hash de senha adequado (ex.: Argon2id) e SHA-256 do token de alta entropia, controlar papéis, congelar o questionário após a abertura, gerir convites e impedir gravações diretas nas tabelas anônimas. A função é SECURITY INVOKER: esta entrega **não implementa** o serviço, a política GRANT/roles nem uma fronteira de segurança contra SQL arbitrário. O acesso a escrita deve ficar em serviço confiável, sem credenciais de banco no navegador. SQL direto privilegiado pode inserir respostas sem consumir tokens; portanto a correspondência entre total de participações e respostas exige o fluxo transacional documentado. Não são implementados edição de pesquisas publicadas nem expurgo administrativo; precisam de projeto próprio.

As funções que consultam/gravam dados fixam `search_path = pg_catalog, public, pg_temp`: tabelas temporárias homônimas não podem desviar as operações. O schema `public` deve permanecer sem permissão CREATE para papéis não confiáveis; a proteção não substitui a política de permissões do backend. A exclusão de participação pendente retorna OLD no gatilho e segue sujeita às FKs; participação concluída permanece imutável. Como gatilhos de linha não protegem contra TRUNCATE nem contra sua desativação por proprietários, esses poderes também não devem ser concedidos a clientes.

## Anonimato

Respostas não contêm usuário, participação, token, IP ou horários. Não há FK nem tabela de correspondência entre identidade e resposta. UUID aleatório evita sequência pública de recebimento. As consultas de resultados retornam somente contagens agrupadas; o controle de participação retorna totais, sem votos individuais.

Isso fornece separação estrutural, **não prova anonimato absoluto**. Categoria de uma única pessoa, comparação entre divulgações sucessivas e combinações raras de alternativas podem revelar respostas. As amostras minúsculas deste exercício são deliberadamente inadequadas à publicação real. Antes de divulgar, definir limiar mínimo de grupo, supressão complementar e política de atualização; não publicar microdados ou cruzamentos pequenos. Nenhum limiar foi inventado aqui.

Logs HTTP/SQL, parâmetros da função, WAL, backups, observação em tempo real e metadados de transação podem correlacionar identidade e resposta. A mesma transação garante integridade, mas um operador privilegiado pode observar a correlação; restringir operadores e logs, redigir payloads/tokens, limitar retenção e proteger backups. Sistemas com adversário privilegiado exigem arquitetura adicional (por exemplo, desacoplamento verificável), fora desta entrega. Não registrar nem devolver UUID de resposta com identidade em logs do backend. Evitar texto livre nesta versão reduz autodeclaração identificável.

Prazo dos tokens e mecanismo de entrega dos resultados continuam **a definir**. O schema não presume expiração nem canal de envio. Encaminhamento ao proprietário depende de implementação e autorização no backend.
