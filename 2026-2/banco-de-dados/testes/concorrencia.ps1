param([string]$HostBanco='127.0.0.1',[int]$Porta=55456,[string]$Usuario='pi_test',[string]$Banco='pi_bd_456')
$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
$argsPsql=@('-h',$HostBanco,'-p',"$Porta",'-U',$Usuario,'-d',$Banco,'-v','ON_ERROR_STOP=1','-X')
# Executar após integridade.sql em banco descartável; deixa 1 participação adicional.
& psql @argsPsql -c "INSERT INTO participacao VALUES(2,5,1,false); INSERT INTO token_acesso VALUES(repeat('f',64),2,5);"
if($LASTEXITCODE -ne 0){throw 'Falha na preparação'}
$jobs=1..2 | ForEach-Object {
 Start-Job -ArgumentList (,$argsPsql) -ScriptBlock {
 param($a)
 [Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
 $out=& psql @a -c "BEGIN; SELECT finalizar_questionario(repeat('f',64),jsonb_build_array(jsonb_build_object('questao_id',1,'opcao_id',1))); SELECT pg_sleep(2); COMMIT;" 2>&1
 [pscustomobject]@{Codigo=$LASTEXITCODE; Saida=($out | Out-String)}
 }
}
$resultados=$jobs | Wait-Job | Receive-Job
$jobs | Remove-Job
$resultados | Select-Object Codigo,Saida | Format-List
if(@($resultados | Where-Object Codigo -eq 0).Count -ne 1){throw 'Esperada exatamente uma finalização bem-sucedida'}
if(@($resultados | Where-Object {$_.Codigo -ne 0 -and $_.Saida -match 'Token inv'}).Count -ne 1){throw 'Esperada rejeição do token na outra sessão'}
$n=& psql @argsPsql -At -c "SELECT (SELECT count(*) FROM resposta_anonima)=5 AND (SELECT count(*) FROM item_resposta)=7 AND (SELECT count(*) FROM token_acesso)=0 AND (SELECT concluida FROM participacao WHERE pesquisa_id=2 AND usuario_id=5);"
if($LASTEXITCODE -ne 0 -or $n -ne 't'){throw 'Contagens finais incorretas'}
Write-Output 'PASSOU: duas sessões disputaram o mesmo token; uma conclusão, uma rejeição, sem duplicação.'
