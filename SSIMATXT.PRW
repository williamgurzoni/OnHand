#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#DEFINE CODIGO 	1
#DEFINE CHAASS	2
#DEFINE FNC		3
#DEFINE CLIENT 	4
#DEFINE PROD	5
#DEFINE CRITIC	6
#DEFINE RESUMO	7
#DEFINE ROTINA	8
#DEFINE STATUS	9
#DEFINE ENTPE	10
#DEFINE GRUPO	11
#DEFINE DTINI_C	12
#DEFINE DTFIM_C	13
#DEFINE ANALI_C	14
#DEFINE CATEG	15
#DEFINE ITEM	16
#DEFINE OCORRE	17
#DEFINE ACAO	18
#DEFINE ANALIS	19
#DEFINE EQUIPE	20
#DEFINE	DATINI	21
#DEFINE HRINI	22
#DEFINE DATFIM	23
#DEFINE HRFIM	24

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : SSIMATXT
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Importação do TXT com chamados
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
User Function SSIMATXT()

Local cBuffer   	:= ""
Local cTitulo1  	:= "Selecione o arquivo"
Local cExtens   	:= "Arquivo CSV | *.csv"

Local aLinha		:= {}

Private cFileOpen 	:= ""
/***
 * _________________________________________________________
 * cGetFile(<ExpC1>,<ExpC2>,<ExpN1>,<ExpC3>,<ExpL1>,<ExpN2>)
 * ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * <ExpC1> - Expressão de filtro
 * <ExpC2> - Titulo da janela
 * <ExpN1> - Numero de mascara default 1 para *.Exe
 * <ExpC3> - Diretório inicial se necessário
 * <ExpL1> - .F. botão salvar - .T. botão abrir
 * <ExpN2> - Mascara de bits para escolher as opções de visualização do objeto
 * (prconst.ch)
 */
 
cFileOpen := cGetFile(cExtens,cTitulo1,,,.T.)

Processa( {|| Import() }, "Processando..." )

Return Nil

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : Import
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Importação do TXT com chamados
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
Static Function Import()

Local lAchouCHA := .F.
Local lFirstCHA	:= .T.

If !File(cFileOpen)
   MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
   Return
Endif

FT_FUSE(cFileOpen)

// Vai ao inicio do arquivo
FT_FGOTOP()

// Pula cabecalho
FT_FSKIP()

ProcRegua(FT_FLASTREC())

DbSelectArea("ZA0")
DbSetOrder(1)

DbSelectArea("ZA1")
DbSetOrder(1)

While !FT_FEOF()	
   	IncProc()
	
	// Zera variavel
	lAchouCHA := .F.
	
	// Ler linha
	cBuffer := FT_FREADLN()    	
	
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	cBuffer := StrTran(cBuffer, ";;", "; ;")
	
	// Transforma linha em array
   	aLinha := StrTokArr(cBuffer, ";")
   	//aLinha := StrTokArr2(cBuffer, ";", .T.) //Para usar este tenho que atualizar a build
	
	If ZA0->(DbSeek(xFilial("ZA0")+aLinha[CODIGO]))
		lAchouCHA := .T.
	EndIf
	
	//If lFirstCHA
		RecLock("ZA0", !lAchouCHA)
		ZA0->ZA0_FILIAL := xFilial("ZA0")
		ZA0->ZA0_CODIGO := aLinha[CODIGO]
		ZA0->ZA0_CLIENT	:= aLinha[CLIENT]
		ZA0->ZA0_CRITIC	:= aLinha[CRITIC]
		ZA0->ZA0_CHAASS	:= aLinha[CHAASS]
		ZA0->ZA0_FNC	:= IIF(Empty(AllTrim(aLinha[FNC])), .F., .T.)
		ZA0->ZA0_PROD	:= aLinha[PROD]
		ZA0->ZA0_ROTINA	:= aLinha[ROTINA]
		ZA0->ZA0_CATEG	:= aLinha[CATEG]
		ZA0->ZA0_RESUMO	:= AllTrim(aLinha[RESUMO])
		ZA0->ZA0_STATUS	:= aLinha[STATUS]
		ZA0->ZA0_GRUPO	:= aLinha[GRUPO]
		ZA0->ZA0_ANALIS	:= aLinha[ANALI_C]
		ZA0->ZA0_DATINI	:= sToD(aLinha[DTINI_C])
		ZA0->ZA0_HRINI	:= "00:00:00" // AJUSTAR A QUERY PARA CAPTURAR ESTA INFORMACAO
		ZA0->ZA0_DATFIM	:= sToD(aLinha[DTFIM_C])
		ZA0->ZA0_HRFIM	:= "00:00:00" // AJUSTAR A QUERY PARA CAPTURAR ESTA INFORMACAO
		ZA0->ZA0_ENTPE	:= aLinha[ENTPE]
		MsUnLock()
		
	//	lFirstCHA := .F.
	//EndIf
	
	If !ZA1->(DbSeek(xFilial("ZA1")+aLinha[CODIGO]+aLinha[ITEM]))
		RecLock("ZA1", .T.)
		ZA1->ZA1_FILIAL := xFilial("ZA1")
		ZA1->ZA1_CODIGO := aLinha[CODIGO]
		ZA1->ZA1_ITEM	:= Replicate("0", 3 - Len(AllTrim(aLinha[ITEM]))) + AllTrim(aLinha[ITEM]) 
		ZA1->ZA1_OCORRE	:= Replicate("0", 6 - Len(AllTrim(aLinha[OCORRE]))) + AllTrim(aLinha[OCORRE])
		ZA1->ZA1_ACAO	:= Replicate("0", 6 - Len(AllTrim(aLinha[ACAO]))) + AllTrim(aLinha[ACAO])
		ZA1->ZA1_ANALIS	:= aLinha[ANALIS]
		ZA1->ZA1_DATA	:= sToD(IIF(!Empty(AllTrim(aLinha[DATINI])), aLinha[DATINI], aLinha[DATFIM]))
		ZA1->ZA1_HORA	:= IIF(TrataHora(aLinha[HRINI]) != "00:00:00", TrataHora(aLinha[HRINI]), TrataHora(aLinha[HRFIM]))
		ZA1->ZA1_EQUIPE	:= aLinha[EQUIPE]
		MsUnLock()
	EndIf
	
   	FT_FSKIP()
EndDo

FT_FUSE()

// Calcula o tempo dos chamados
U_SSIMA010()

MsgInfo("Processo finalizada")

Return Nil

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : TrataHora
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 31/10/15 | Trata a hora do chamado
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
Static Function TrataHora(cHora)

Local cRet := ""

cHora := AllTrim(cHora)

If(Len(cHora) == 5)
	cRet := cHora + ":00"
Else
	cRet := "00:00:00"
EndIf

Return cRet


