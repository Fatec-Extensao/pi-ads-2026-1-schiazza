$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap 1900,1500
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::White)
$g.SmoothingMode = 'AntiAlias'
$font = New-Object System.Drawing.Font 'Arial',17
$titleFont = New-Object System.Drawing.Font 'Arial',25,([System.Drawing.FontStyle]::Bold)
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(55,85,115)),2
$brush = [System.Drawing.Brushes]::Black
$svg = [System.Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1900" height="1500" viewBox="0 0 1900 1500"><rect width="1900" height="1500" fill="white"/>')
function Label($x,$y,$s,$heading=$false) {
 $f=$font; if($heading){$f=$titleFont}
 $g.DrawString($s,$f,$brush,$x,$y)
 $safe=[System.Security.SecurityElement]::Escape($s)
 $size=23; if($heading){$size=34}
 $svg.Add("<text x='$x' y='$($y+28)' font-family='Arial' font-size='$size'>$safe</text>")
}
function Box($x,$y,$name,$attrs) {
 $g.FillRectangle([System.Drawing.Brushes]::AliceBlue,$x,$y,470,150)
 $g.DrawRectangle($pen,$x,$y,470,150)
 $svg.Add("<rect x='$x' y='$y' width='470' height='150' fill='#f0f8ff' stroke='#375573' stroke-width='2'/>")
 Label ($x+15) ($y+10) $name $true
 $n=0; foreach($a in $attrs){Label ($x+15) ($y+60+$n*30) $a; $n++}
}
function Edge($x1,$y1,$x2,$y2,$label,$lx,$ly) {
 $g.DrawLine($pen,$x1,$y1,$x2,$y2)
 $svg.Add("<line x1='$x1' y1='$y1' x2='$x2' y2='$y2' stroke='#375573' stroke-width='2'/>")
 Label $lx $ly $label
}
Label 70 25 'MER / DER — Sistema Web para Gestão de Pesquisas por Questionários' $true
Label 70 80 'Cardinalidades: cada filho pertence a 1 pai; rótulos indicam filhos por pai.'
Box 70 170 'USUARIO' @('identificador, nome, email','hash da senha')
Box 710 170 'PESQUISA' @('identificador, título','administra / possui: papéis do usuário')
Box 1350 170 'CATEGORIA' @('identificador local, nome','pertence à pesquisa')
Box 70 570 'PARTICIPACAO' @('usuário + pesquisa (únicos)','categoria, concluída')
Box 710 570 'TOKEN_ACESSO' @('hash do token ativo','vínculo removido ao concluir')
Box 1350 570 'QUESTAO' @('identificador local, enunciado','uma categoria por questão')
Box 70 1000 'RESPOSTA_ANONIMA' @('identificador aleatório','contexto: pesquisa e categoria')
Box 710 1000 'ITEM_RESPOSTA' @('questão respondida','opção selecionada')
Box 1350 1000 'OPCAO' @('identificador local, descrição','uma questão por opção')
Edge 540 240 710 240 '0:N por papel' 545 120
Edge 1180 240 1350 240 '0:N contém' 1190 190
Edge 300 320 300 570 '0:N participa' 80 420
Edge 710 290 540 570 '0:N convites' 510 410
Edge 540 645 710 645 '0:1 ativo' 560 600
Edge 1580 320 1580 570 '0:N questões' 1590 420
Edge 1580 720 1580 1000 '0:N opções' 1590 835
Edge 540 1075 710 1075 '1:N itens' 555 1025
Edge 1180 1075 1350 1075 '0:N itens' 1190 1025
Edge 1350 300 1250 375 '0:N participações' 1000 335
Edge 1250 375 400 570 '' 900 430
Edge 1820 290 1860 290 '' 0 0
Edge 1860 290 1860 1250 '0:N respostas' 1610 1190
Edge 1860 1250 300 1250 '' 0 0
Edge 300 1250 300 1150 '' 0 0
Label 70 1330 'Não há vínculo entre identidade / token / participação e resposta anônima.' $true
Label 70 1390 'N:M usuário–pesquisa resolvido por PARTICIPACAO; resposta–opção por ITEM_RESPOSTA.'
$svg.Add('</svg>')
$bmp.Save((Join-Path $PSScriptRoot '../modelo-conceitual.png'),[System.Drawing.Imaging.ImageFormat]::Png)
[System.IO.File]::WriteAllLines((Join-Path $PSScriptRoot 'modelo-conceitual.svg'),$svg,[System.Text.UTF8Encoding]::new($false))
$g.Dispose(); $bmp.Dispose(); $font.Dispose(); $titleFont.Dispose(); $pen.Dispose()
