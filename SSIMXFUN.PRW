#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : RetT
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Esta função retornará a diferença entre duas datas / horas descontando 
//          | o horário de intervalo e tempo útil de trabalho
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
User function RetT(dDataIni, cHoraIni, dDataFim, cHoraFim)

Local nMinutos := 0
Local nQtdDias := 0
Local nI := 1

Private cIniExp 	:= "08:00:00"
Private cIniPausa 	:= "12:00:00"
Private cFimPausa	:= "13:30:00"
Private cFimExp		:= "18:00:00"

If dDataIni == dDataFim
	
	// Verifica se as duas interações foram realizadas no mesmo período (antes ou depois do descanso)
	If (cHoraIni <=  cIniPausa .And. cHoraFim <= cIniPausa) .Or. (cHoraIni >= cFimPausa .And. cHoraFim >= cFimPausa) 
		nMinutos := U_HoraToMin(ElapTime(cHoraIni, cHoraFim))
	Else
		// Desconta o horário da pausa
		nMinutos := U_HoraToMin(ElapTime(cHoraIni, cHoraFim))
		nMinutos -= U_HoraToMin(ElapTime(cIniPausa, cFimPausa))
	EndIf
	
Else
	// Caso as datas sejam diferentes, deverá considerar os dias cheios mais o dia incompleto
	// neste caso verificar a diferença dos horários subtraindo 90 minutos de almoco
	
	// Calcula tempo gasto no primeiro dia
	nMinutos := U_HoraToMin(ElapTime(cHoraIni, cFimExp))
	If cHoraIni <= cIniPausa		
		nMinutos -= U_HoraToMin(ElapTime(cIniPausa, cFimPausa)) //Desconta horario de pausa
	EndIf
	
	// Calcula tempo gasto no ultimo dia
	nMinutos += U_HoraToMin(ElapTime(cIniExp, cHoraFim))
	If cHoraFim >= cFimPausa
		nMinutos -= U_HoraToMin(ElapTime(cIniPausa, cFimPausa)) //Desconta horario de pausa
	EndIf
	
	// Caso a diferença de datas tenha sido maior que um dia, calcula as horas dos 
	// dias despendidos para a analise, desconsiderando finais de semana e feriados
	nQtdDias := dDataFim - dDataIni - 1
	
	While nI < nQtdDias
		If DataValida(dDataIni + nI, .T.) == dDataIni + nI				
			nMinutos += 60 * 8.5
		EndIf
		nI++
	EndDo
EndIf

Return nMinutos

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : HoraToMin
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Esta função receberá a hora em formato 00:00 e retornará em minutos no 
//          | formato numerico
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
User Function HoraToMin(cHora)
	
Local nMin := 0

nMin := Val(SubStr(cHora, 1, 2)) * 60
nMin += Val(SubStr(cHora, 4, 2))

Return nMin

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : AcertaHR
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 25/10/15 | Ajusta horário de intervalo
//			| Caso a interação tenha sido feita no horário de intervalo, considera o horário
//			| Anterior ou posterior, de acordo com a variável INI / FIM 
//			| As variáveis devem ser passadas por referência
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
User function AcertaHR(dData, cHora, lTotvs)

Local dDtValida

Private cIniExp 	:= "08:00:00"
Private cIniPausa 	:= "12:00:00"
Private cFimPausa	:= "13:30:00"
Private cFimExp		:= "18:00:00"

// Primeiramente verificar através da função específica se a data é final de semana ou feriado.
// O cadastro de feriados é realizado pela SX5 - tabela 63. O sábodo é considerado de acordo com 
// o parâmetro MV_SABFERI = S

dDtValida := DataValida(dData, !lTotvs)

If dData != dDtValida
	If lTotvs
		dData := dDtValida
		cHora := cFimExp
	Else
		dData := dDtValida
		cHora := cIniExp
	EndIf
Else
	If lTotvs
		// Se o analista inseriu uma interação fora do expediente, a interação
		// é considerada como sendo no final do expediente, mesmo se foi feita no dia seguinte
		// Se foi feita no dia seguinte, deverá retroceder a data
		If cHora <= cIniExp .Or. cHora >= cFimExp
			cHora := cFimExp
			
		// Se o analista inseriu a interação no horário de pausa, a interação
		// é considerada como sendo no início da pausa
		ElseIf cHora >= cIniPausa .And. cHora <= cFimPausa
			cHora := cIniPausa
		EndIf
	Else
		// Se o cliente inseriu a interação fora do expediente, a interação
		// é considerada como sendo no início do expediente
		If cHora <= cIniExp .Or. cHora >= cFimExp
			cHora := cIniExp
		
		// Se o cliente inseriu a interação no horário de pausa, a interação
		// é considerada como sendo no final da pausa
		ElseIf cHora >= cIniPausa .And. cHora <= cFimPausa
			cHora := cFimPausa
		EndIf
	EndIf
EndIf

Return NIL
