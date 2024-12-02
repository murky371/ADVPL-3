#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'          
#INCLUDE 'FwEditPanel.ch
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} TSTCP
FunÃ§Ã£o para criar o programa de Pedidos acessando as tabelas ZB1, ZB2 e ZB3
@type function
@version  
@author Joao Goncalves
@since 02/12/2024
@return Sem retorno
/*/
User Function TSTCP()
Local oBrowse    //Digo o fonte que eu estou buscando o BrowseDef

oBrowse := FWmBrowse():New()

oBrowse:SetDescription("Cultura x Produto e Manutencao de Comissao")

oBrowse:SetAlias("ZB1") 


oBrowse:Activate()
return


/*/{Protheus.doc} MenuDef
description
@type function
@version  
@author Joao Goncalves
@since 02/12/2024
@return aRotina
/*/
Static Function MenuDef()
Local aRotina     := {}

ADD OPTION aRotina    TITLE "Visualizar"      ACTION "VIEWDEF.TSTCP"    OPERATION     2 ACCESS 0 
ADD OPTION aRotina    TITLE "Incluir"         ACTION "VIEWDEF.TSTCP"    OPERATION     3 ACCESS 0
ADD OPTION aRotina    TITLE "Alterar"         ACTION "VIEWDEF.TSTCP"    OPERATION     4 ACCESS 0
ADD OPTION aRotina    TITLE "Excluir"         ACTION "VIEWDEF.TSTCP"    OPERATION     5 ACCESS 0

return aRotina


/*/{Protheus.doc} ModelDef
Funcao Modelo do MVC - Esta funcao responsavel pela montagem da estrutura dos dados
@type function
@version  
@author Joao Goncalves
@since 29/06/2021
@return oModel
/*/
Static Function ModelDef()
//Declaro o meu modelo de dados sem passar blocos de validaÃ§Ã£o pois usaremos a validaÃ§Ã£o padrÃ£o do MVC
Local oPaiZB1      := FwFormStruct(1,"ZB1") //Master
Local oFilhoZB2    := FwFormStruct(1,"ZB2") //Detalhe
Local oFilhoZB3    := FwFormStruct(1,"ZB3") //Detalhe

Local oModel       := MPFormModel():New("PTSTCP",/*bPre*/, /*bPos*/,  /*bCommit*/,/*bCancel*/)

//Crio as estruturas das tabelas PAI(SZ5) e FILHO(SZ6)

//Crio Modelos de dados CabeÃ§alho e Item
oModel:AddFields("ZB1MASTER",,oPaiZB1)

oModel:AddGrid("ZB2DETAIL","ZB1MASTER",oFilhoZB2,,,,,)//ESSAS vÃ­rgulas em branco, sÃ£o blocos de validaÃ§Ã£o que nÃ£o vamos usar

oModel:AddGrid("ZB3DETAIL","ZB2DETAIL",oFilhoZB3,,,,,)//ESSAS vÃ­rgulas em branco, sÃ£o blocos de validaÃ§Ã£o que nÃ£o vamos usar

//O meu grid, irÃ¡ se relacionar com o cabeÃ§alho, atravÃ©s dos campos FILIAL e CODIGO DE Pedido

oModel:SetRelation("ZB2DETAIL",{{"ZB2_FILIAL","xFILIAL('ZB2')"}, {"ZB2_CDIAG", "ZB1_CDIAG"}},ZB2->(IndexKey(1)))

oModel:SetRelation("ZB3DETAIL",{{"ZB3_FILIAL","xFILIAL('ZB3')"}, {"ZB3_CDIAG", "ZB2_CDIAG"}},ZB3->(IndexKey(1)))

//Posso pegar a chave primÃ¡ri da SX2 atravÃ©s do X2_UNICO
//Setamos a chave primÃ¡ria, prevalece o que estÃ¡ na SX2(X2_UNICO), se na X2 estiver preenchido
//NÃ£o podemos ter dentro de uma Pedido, dois comentÃ¡rios com o mesmo cÃ³digo
oModel:SetPrimarykey({"ZB1_FILIAL","ZB1_CODCUL"})

oModel:GetModel("ZB2DETAIL"):SetUniqueLine({"ZB2_CDIAG"})

oModel:GetModel("ZB3DETAIL"):SetUniqueLine({"ZB3_CDIAG"})

oModel:SetDescription("Culturas x Produtos")

oModel:GetModel("ZB1MASTER"):SetDescription("Culturas")

oModel:GetModel("ZB2DETAIL"):SetDescription("Diagnosticos")

oModel:GetModel("ZB3DETAIL"):SetDescription("Manutencao de Comissao")

Return oModel


/*/{Protheus.doc} ViewDef
FunÃ§Ã£o ResponsÃ¡vel pela parte visual do Programa
@type function
@version  
@author Joao Goncalves
@since 02/12/2024
@return oView
/*/
Static Function ViewDef()
Local oView     

//Invoco o Model da funÃ§Ã£o que quero
Local oModel    := FwLoadModel("TSTCP")

Local oPaiZB1      := FwFormStruct(2,"ZB1")

Local oFilhoZB2    := FwFormStruct(2,"ZB2") //Detalhe

Local oFilhoZB3    := FwFormStruct(2,"ZB3") //Detalhe

oView   := FwFormView():New()

oView:SetModel(oModel)

//Crio as views/visÃµes/layout de cabeÃ§alho e item, com as estruturas de dados criadas acima
oView:AddField("VIEWZB1",oPaiZB1,"ZB1MASTER")

oView:AddGrid("VIEWZB2",oFilhoZB2,"ZB2DETAIL")

oView:AddGrid("VIEWZB3",oFilhoZB3,"ZB3DETAIL")

//FaÃ§o o campo de Item ficar incremental
oView:AddIncrementField("ZB2DETAIL","ZB2_CDIAG") //Soma 1 ao campo de Item

oView:AddIncrementField("ZB3DETAIL","ZB3_CDIAG") //Soma 1 ao campo de Item


//Criamos os BOX horizontais para CABEÃ‡ALHO E ITENS
oView:CreateHorizontalBox("CABEC",30) //30% Para cabeçalho

oView:CreateHorizontalBox("GRID1",35)  //35% para itens

oView:CreateHorizontalBox("GRID2",35)  //35% para itens


//Amarro as views criadas aos BOX criados
oView:SetOwnerView("VIEWZB1","CABEC")

oView:SetOwnerView("VIEWZB2","GRID1")

oView:SetOwnerView("VIEWZB3","GRID2")


//Darei tÃ­tulos personalizados ao cabeÃ§alho e comentÃ¡rios do Pedido
oView:EnableTitleView("VIEWZB1","Culturas")

oView:EnableTitleView("VIEWZB2","Diagnostico")

oView:EnableTitleView("VIEWZB3","Manutencao de Comissao")


return oView




