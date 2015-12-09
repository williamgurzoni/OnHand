#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : SSIMA100
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | Rotina de visualização dos chamados 
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
User Function SSIMA100

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZA0')
oBRowse:SetDescription('Chamados SSIM')

// Criação da Legenda
oBrowse:AddLegend("ZA0_FILIAL=='01'", "BR_BRANCO"	, "Em Edição")
//oBrowse:AddLegend("UO0_STATUS=='P'", "PMSEDT3"		, "Pedido gerado")
//oBrowse:AddLegend("UO0_STATUS=='X'", "PMSEDT1"		, "Pedido gerado por outra revisão")

oBrowse:Activate()

Return NIL

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : SSIMA100
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | MenuDef 
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.SSIMA100' 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Recalcular'	Action 'U_SSIMA010()'	 	OPERATION 10 ACCESS 0
ADD OPTION aRotina Title 'Imp. Dados'	Action 'U_SSIMATXT()'		OPERATION 11 ACCESS 0
/*
ADD OPTION aRotina Title 'Incluir' 		Action 'VIEWDEF.SSIMA100' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 		Action 'VIEWDEF.SSIMA100' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 		Action 'VIEWDEF.SSIMA100' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 	Action 'U_xxx' 		 		OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Copiar' 		Action 'VIEWDEF.SSIMA100' 	OPERATION 9 ACCESS 0
*/

Return aRotina

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : SSIMA100
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | ModelDef
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
Static Function ModelDef()

Local oStruZA0 	:= FWFormStruct(1, 'ZA0')
Local oStruZA1 	:= FWFormStruct(1, 'ZA1')

Private oModel

oModel := MPFormModel():New('MODELZA0')

//Adciona ao modelo um componente de formulario
oModel:AddFields('ZA0MASTER', /*cOwner*/, oStruZA0)
oModel:AddGrid('ZA1DETAIL', 'ZA0MASTER', oStruZA1)

//Definindo o relacionamento entre as entidades
oModel:SetRelation('ZA1DETAIL', {{'ZA1_FILIAL', 'xFilial("ZA1")'},;
	{'ZA1_CODIGO', 'ZA0_CODIGO'}}, ZA1->(IndexKey(1)))
	
//Set primary key
oModel:SetPrimaryKey({'ZA0_FILIAL', 'ZA0_CODIGO'})

//Seta descrição ao modelo e seus componentes
oModel:SetDescription('Chamados SSIM TOTVS')
oModel:GetModel('ZA0MASTER'):SetDescription('Chamado')
oModel:GetModel('ZA1DETAIL'):SetDescription('Itens')

// Deixa os grids opcionais
oModel:GetModel('ZA1DETAIL'):SetOptional(.T.)

// Bloqueia deleção de linhas da grid
//oModel:GetModel('ZA1DETAIL'):SetNoDeleteLine(.T.)

Return oModel

// #########################################################################################
// Projeto: SSIM Controle
// Modulo : SIGATMK
// Rotina : SSIMA100
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor: William Gurzoni 
// ---------+-------------------+-----------------------------------------------------------
// 24/10/15 | ViewDef
// ---------+-------------------+-----------------------------------------------------------
// #########################################################################################
Static Function ViewDef()

// Resgatando modelo que será utilizado
Local oModel 	:= FWLoadModel('SSIMA100')
Local oStruZA0 	:= FWFormStruct( 2, 'ZA0' )
Local oStruZA1 	:= FWFormStruct( 2, 'ZA1' )
Private oView	:= FWFormView():New()

// Removendo os campos desnecessários aos usuários
oStruZA1:RemoveField('ZA1_CODIGO')

// Definindo o modelo da view
oView:SetModel(oModel)

oView:AddField('VIEW_ZA0', oStruZA0, 'ZA0MASTER')

// Adicionando os grids
oView:AddGrid('VIEW_ZA1', oStruZA1, 'ZA1DETAIL')

// Adicionando o painel de totais - RODAPE
//oView:AddOtherObject('VIEW_ROD', {|oPanel| A050RODAPE(oPanel)})

// Dividindo a tela
oView:CreateHorizoltalBox('SUPERIOR', 55)
oView:CreateHorizoltalBox('INFERIOR', 45)
//oView:CreateHorizontalBox('RODAPE',7)

// Definindo a localização dos objetos
oView:SetOwnerView('VIEW_ZA0', 'SUPERIOR')
oView:SetOwnerView('VIEW_ZA1', 'INFERIOR')
//oView:SetOwnerView('VIEW_ROD', 'RODAPE')

// Adiciona botões na tela
//oView:AddUserButton('Recalcular', 'MAGIC_BMP', {U_LOOPTMK()})

// Habilita título nos grids
oView:EnableTitleView("VIEW_ZA1", "Interacoes")

// Agrupa campos
//oStruUO0:AddGroup('GRUPO01', 'Dados Principais', '', 1)
//oStruUO0:AddGroup('GRUPO02', 'Negociação', '', 1)

// Coloca todos os campos no agrupamento padrão
//oStruUO0:SetProperty('*' 		, MVC_VIEW_GROUP_NUMBER, 'GRUPO01')

// Divede os outros campos em agrupamentos menores
//oStruUO0:SetProperty('UO0_DESC'		, MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
//oStruUO0:SetProperty('UO0_FRETEE'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03')

Return oView
