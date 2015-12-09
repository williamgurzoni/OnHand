#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : SSIMA010
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Esta função calculará o tempo dos chamados 
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
User Function SSIMA010()

Processa( {|| LoopTMK() }, "Calculando tempo do chamado..." )	
	
Return

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : LoopTMK
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Esta função calculará o tempo dos chamados 
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
Static Function LoopTMK

Local nMinFX1	:= 0	// Minutos na faixa 1
Local nMinAna	:= 0	// Minutos com o analista
Local nMinCli	:= 0	// Minutos com o cliente
Local nMinMax	:= 0	// Minutos máximo para atendimento do chamado
Local lCtrFX1	:= .F.	// Bateu faixa 1 ?

// Variáveis de controle do looping
Local dDataIni
Local dDataFim
Local cHoraIni
Local cHoraFim 
Local lSetIni	:= .F.
Local lSetFX1	:= .F.

// Abre tabela de chamados
DbSelectArea("ZA0")
ZA0->(DbSetOrder(1))
ZA0->(DbGoTop())

// Abre tabela de itens
DbSelectArea("ZA1")
ZA1->(DbSetOrder(1))

// Percorre chamados
While !ZA0->(EOF())
	
	//Limpa variáveis dos tempos por chamado
	nMinFX1	:= 0	
	nMinAna	:= 0	
	nMinCli	:= 0
	nMinMax	:= 0
	lSetFX1	:= .F.	
	lSetIni := .F.
	lCtrFX1 := .F.
	dDataIni := cToD("  /  /  ")
	dDataFim := cToD("  /  /  ")
	cHoraIni := ""
	cHoraFim := ""
	
	// Percorre itens dos chamados
	If ZA1->(DbSeek(xFilial("ZA1")+ZA0->ZA0_CODIGO))
		While !ZA1->(EOF()) .And. ZA0->ZA0_CODIGO == ZA1->ZA1_CODIGO
			
			// Verifica se ação não altera tempo
			If (ZA1->ZA1_ACAO $ "|000010|000028|000102|000142||") .Or. (ZA1->ZA1_OCORRE $ "|P00003|SSIM18|")				
				ZA1->(DbSkip())
				Loop
			EndIf
			
			// Seta variaveis dos tempos iniciais
			If !lSetIni .And. (ZA1->ZA1_ACAO $ "|000001|000100|000101|" .Or. ZA1->ZA1_OCORRE $ "|P00004|")
				dDataIni := ZA1->ZA1_DATA
				cHoraIni := ZA1->ZA1_HORA
				lSetIni := .T.
				
			// Calcula o tempo da faixa 1
			ElseIf lSetIni .And. !lSetFX1 .And. (ZA1->ZA1_ACAO $ "|000019|000024|000025|000036|SSIM50|")				
				dDataFim := ZA1->ZA1_DATA
				cHoraFim := ZA1->ZA1_HORA
				
				// Ajusta horários
				// Verifica e ajusta caso a interação tenha sido realizada fora 
				// Do horário de expediente
				// No terceiro parâmetro informar se a interação é TOTVS
				U_AcertaHR(@dDataIni, @cHoraIni, .F.) 
				U_AcertaHR(@dDataFim, @cHoraFim, .T.)
				
				nMinFX1 := U_RetT(dDataIni, cHoraIni, dDataFim, cHoraFim)
				lSetFX1 := .T.
			EndIf	
			
			// Seta variáveis dos tempos finais | paraliza contagem
			If lSetIni .And. (ZA1->ZA1_ACAO $ "|000018|000019|000023|000024|000025|000036|000140|003000|960001|")
				dDataFim := ZA1->ZA1_DATA
				cHoraFim := ZA1->ZA1_HORA
				
				// Ajusta horários
				// Verifica e ajusta caso a interação tenha sido realizada fora 
				// Do horário de expediente
				// No terceiro parâmetro informar se a interação é TOTVS
				U_AcertaHR(@dDataIni, @cHoraIni, .F.) 
				U_AcertaHR(@dDataFim, @cHoraFim, .T.)				
				
				// Sempre que paraliza a cotagem, calcular o tempo de atendimento
				nMinAna += U_RetT(dDataIni, cHoraIni, dDataFim, cHoraFim)
				lSetIni := .F.
				dDataIni := cToD("  /  /  ")
				dDataFim := cToD("  /  /  ")
				cHoraIni := ""
				cHoraFim := ""
			EndIf
			
			ZA1->(DbSkip())
		EndDo
	EndIf
	
	If nMinFX1 < 60
		lCtrFX1 := .T.	
	EndIf
	
	RecLock("ZA0", .F.)
	ZA0->ZA0_MINANA := nMinAna
	ZA0->ZA0_MINFX1 := nMinFX1
	ZA0->ZA0_CTRFX1	:= lCtrFX1
	MsUnLock()
	
	ZA0->(DbSkip())
EndDo

Return
