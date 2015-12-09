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

Private cIniExp 	:= "08:00:00"
Private cIniPausa 	:= "12:00:00"
Private cFimPausa	:= "13:30:00"
Private cFimExp		:= "18:00:00"

If dDataIni == dDataFim
	
	// Verifica se a interação foi realizada no horário do intervalo
	If (cHoraIni <=  "12:00:00" .And. cHoraFim <= "12:00:00") .Or. (cHoraIni >= "13:30:00" .And. cHoraFim >= "13:30:00") 
		nMinutos := U_HoraToMin(ElapTime(cHoraIni, cHoraFim))
	Else
		nMinutos := U_HoraToMin(ElapTime(cHoraIni, cHoraFim))
		nMinutos -= 90
	EndIf
	
Else
	// Caso as datas sejam diferentes, deverá os dias cheios mais o dia incompleto
	// neste caso verificar a diferença dos horários subtraindo 90 minutos de almoco
	
	// Calcula tempo gasto no primeiro dia
	nMinutos := U_HoraToMin(ElapTime(cHoraIni, "18:00:00"))
	If cHoraIni <= cIniPausa		
		nMinutos -= 90 //Desconta horario de almoco
	EndIf
	
	// Calcula tempo gasto no ultimo dia
	nMinutos += U_HoraToMin(ElapTime("08:00:00", cHoraFim))
	If cHoraFim >= "13:30:00"
		nMinutos -= 90
	EndIf
	
	// Caso a diferença de datas tenha sido maior que um dia, calcula as horas dos 
	// dias despendidos para a analise
	nQtdDias := dDataFim - dDataIni
	If nQtdDias > 1
		nMinutos += (nQtdDias - 1) * 60 * 8.5
	EndIf
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

Private cIniExp 	:= "08:00:00"
Private cIniPausa 	:= "12:00:00"
Private cFimPausa	:= "13:30:00"
Private cFimExp		:= "18:00:00"

// Primeiramente verificar através da função específica se a data é final de semana
// ou feriado.
//-------

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


/*
If AllTrim(cHoraIni) != "" .And. AllTrim(cHoraFim) != ""
	// Verifica se as duas interações foram realizadas fora do horário comercial	
	If cHoraIni <= cIniExp .And. cHoraFim <= cIniExp
		cHoraIni := cIniExp
		cHoraFim := cIniExp
	EndIf
	If cHoraIni >= cFimExp .And. cHoraFim >= cFimExp
		cHoraIni := cFimExp
		cHoraFim := cFimExp
	EndIf
	If cHoraIni >= cIniPausa .And. cHoraIni <= cFimPausa .And. cHoraFim >= cIniPausa .And. cHoraFim <= cFimPausa
		cHoraIni := cFimPausa
		cHoraFim := cFimPausa
	EndIf 

	// Verifica se a interação foi realizada fora do horário comercial
	If cHoraIni <= cIniExp .Or. cHoraIni >= cFimExp
		cHoraIni := cIniExp
	EndIf 
	
	// Verifica se a interação foi realizada no horário de intervalo
	If cHoraIni >= cIniPausa .And. cHoraIni <= cFimPausa
		cHoraIni := cFimPausa
	EndIf

	// Verifica se a interação foi realizada fora do horário comercial
	If cHoraFim <= cIniExp .Or. cHoraFim >= cFimExp
		cHoraFim := cIniExp //antes estava parada2
	EndIf 
	
	// Verifica se a interação foi realizada no horário de intervalo
	If cHoraFim >= cIniPausa .And. cHoraFim <= cFimPausa
		cHoraFim := cIniPausa
	EndIf
EndIf
*/
	
Return NIL
