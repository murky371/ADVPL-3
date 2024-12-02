#INCLUDE 'Totvs.ch'
#INCLUDE 'Fwmvcdef.ch'          
#INCLUDE 'FwEditPanel.ch
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} TSTCP
Função para criar o programa de Pedidos acessando as tabelas SZ5 e SZ6
@type function
@version  
@author Joao Goncalves
@since 29/06/2021
@return Sem retorno
/*/
User Function TSTCP()
Local oBrowse    //Digo o fonte que eu estou buscando o BrowseDef

//Private aRotina  := MenuDef()

oBrowse := FWmBrowse():New()

oBrowse:SetDescription("Cultura x Produto e Manutencao de Comissao")

oBrowse:SetAlias("ZB1") //Cabeçalho


//oBrowse:SetMenuDef("TESTECP")

oBrowse:Activate()
return


/*/{Protheus.doc} BrowseDef
Static Function responsável pela Criação
@type function
@version  
@author Joao Goncalves
@since 29/06/2021
@return oBrowse
/*/
/*
Static Function BrowseDef()
Local oBrowse   := FwMBrowse():New()

oBrowse:SetAlias("ZB1") //Cabeçalho
oBrowse:SetDescription("Cultura x Diagnostico x Produto")

//oBrowse:AddLegend("SZ5->Z5_STATUS == '1'","GREEN"   ,"Pedido em Aberto")
//oBrowse:AddLegend("SZ5->Z5_STATUS == '2'","RED"     ,"Pedido em Finalizado")
//oBrowse:AddLegend("SZ5->Z5_STATUS == '3'","YELLOW"  ,"Pedido em Liberação")

oBrowse:SetMenuDef("AGRIQAL")

return oBrowse
*/

Static Function MenuDef()
Local aRotina     := {}

ADD OPTION aRotina    TITLE "Visualizar"      ACTION "VIEWDEF.TSTCP"    OPERATION     2 ACCESS 0 
ADD OPTION aRotina    TITLE "Incluir"         ACTION "VIEWDEF.TSTCP"    OPERATION     3 ACCESS 0
ADD OPTION aRotina    TITLE "Alterar"         ACTION "VIEWDEF.TSTCP"    OPERATION     4 ACCESS 0
ADD OPTION aRotina    TITLE "Excluir"         ACTION "VIEWDEF.TSTCP"    OPERATION     5 ACCESS 0
//ADD OPTION aMenu    TITLE 'Legenda'         ACTION 'u_SZ5LEG'          OPERATION    6 ACCESS 0
//ADD OPTION aMenu    TITLE 'Sobre'           ACTION 'u_SZ5SOBR'         OPERATION    6 ACCESS 0

/*
2   VISUALIZAÇÃO
3   INCLUSÃO
4   ALTERAÇÃO
5   EXCLUSÃO
6   FUNÇÕES EXTRAS(SOBRE E LEGENDA) 
*/
return aRotina


/*/{Protheus.doc} ModelDef
Funcao Modelo do MVC - Esta funcao responsavel pela montagem da estrutura dos dados
@type function
@version  
@author Joao Goncalves
@since 29/06/2021
@return variant, return_description
/*/
Static Function ModelDef()
//Declaro o meu modelo de dados sem passar blocos de validação pois usaremos a validação padrão do MVC
Local oPaiZB1      := FwFormStruct(1,"ZB1") //Master
Local oFilhoZB2    := FwFormStruct(1,"ZB2") //Detalhe
Local oFilhoZB3    := FwFormStruct(1,"ZB3") //Detalhe

Local oModel       := MPFormModel():New("PTSTCP",/*bPre*/, /*bPos*/,  /*bCommit*/,/*bCancel*/)

//Crio as estruturas das tabelas PAI(SZ5) e FILHO(SZ6)

//Crio Modelos de dados Cabeçalho e Item
oModel:AddFields("ZB1MASTER",,oPaiZB1)
oModel:AddGrid("ZB2DETAIL","ZB1MASTER",oFilhoZB2,,,,,)//ESSAS vírgulas em branco, são blocos de validação que não vamos usar
oModel:AddGrid("ZB3DETAIL","ZB2DETAIL",oFilhoZB3,,,,,)//ESSAS vírgulas em branco, são blocos de validação que não vamos usar

//O meu grid, irá se relacionar com o cabeçalho, através dos campos FILIAL e CODIGO DE Pedido

oModel:SetRelation("ZB2DETAIL",{{"ZB2_FILIAL","xFILIAL('ZB2')"}, {"ZB2_CDIAG", "ZB1_CDIAG"}},ZB2->(IndexKey(1)))

oModel:SetRelation("ZB3DETAIL",{{"ZB3_FILIAL","xFILIAL('ZB3')"}, {"ZB3_CDIAG", "ZB2_CDIAG"}},ZB3->(IndexKey(1)))

//Posso pegar a chave primári da SX2 através do X2_UNICO
//Setamos a chave primária, prevalece o que está na SX2(X2_UNICO), se na X2 estiver preenchido
//Não podemos ter dentro de uma Pedido, dois comentários com o mesmo código
oModel:SetPrimarykey({"ZB1_FILIAL","ZB1_CODCUL"})

oModel:GetModel("ZB2DETAIL"):SetUniqueLine({"ZB2_CDIAG"})
oModel:GetModel("ZB3DETAIL"):SetUniqueLine({"ZB3_CDIAG"})

oModel:SetDescription("Culturas x Produtos")
oModel:GetModel("ZB1MASTER"):SetDescription("Culturas")
oModel:GetModel("ZB2DETAIL"):SetDescription("Diagnosticos")
oModel:GetModel("ZB3DETAIL"):SetDescription("Manutencao de Comissao")

Return oModel


/*/{Protheus.doc} ViewDef
Função Responsável pela parte visual do Programa
@type function
@version  
@author Joao Goncalves
@since 29/06/2021
@return variant, return_description
/*/
Static Function ViewDef()
Local oView     

//Invoco o Model da função que quero
Local oModel    := FwLoadModel("TSTCP")

Local oPaiZB1      := FwFormStruct(2,"ZB1")
Local oFilhoZB2    := FwFormStruct(2,"ZB2") //Detalhe
Local oFilhoZB3    := FwFormStruct(2,"ZB3") //Detalhe



//Removo o campo para não aparecer, já que ele estará sendo preenchido automaticamente pelo código do Pedido do cabeçalho
//oFilhoZB2:RemoveField("ZB2_CDIAG")
//oFilhoZB3:RemoveField("ZB3_CDIAG")

//Travo o campo de Codigo para não ser editado, ou seja, o campo CODIGO DE COMENTARIO do Pedido, será automático e não poderá ser modificado
//oStFilhoZ6:SetProperty("Z6_ITEM",    MVC_VIEW_CANCHANGE, .F.)

//Travo o campo de TOTAL
//oStFilhoZ6:SetProperty("Z6_VALOR",    MVC_VIEW_CANCHANGE, .F.)

  
//Faço a instancia da função FwFormView para a variável oView
oView   := FwFormView():New()

oView:SetModel(oModel)

//Crio as views/visões/layout de cabeçalho e item, com as estruturas de dados criadas acima
oView:AddField("VIEWZB1",oPaiZB1,"ZB1MASTER")
oView:AddGrid("VIEWZB2",oFilhoZB2,"ZB2DETAIL")
oView:AddGrid("VIEWZB3",oFilhoZB3,"ZB3DETAIL")

//Faço o campo de Item ficar incremental
oView:AddIncrementField("ZB2DETAIL","ZB2_CDIAG") //Soma 1 ao campo de Item
oView:AddIncrementField("ZB3DETAIL","ZB3_CDIAG") //Soma 1 ao campo de Item

//Criamos os BOX horizontais para CABEÇALHO E ITENS
oView:CreateHorizontalBox("CABEC",30) //760% do tamanho para cabeçalho
oView:CreateHorizontalBox("GRID1",35)  //40% para itens
oView:CreateHorizontalBox("GRID2",35)  //40% para itens

//Amarro as views criadas aos BOX criados
oView:SetOwnerView("VIEWZB1","CABEC")
oView:SetOwnerView("VIEWZB2","GRID1")
oView:SetOwnerView("VIEWZB3","GRID2")

//Darei títulos personalizados ao cabeçalho e comentários do Pedido
oView:EnableTitleView("VIEWZB1","Culturas")
oView:EnableTitleView("VIEWZB2","Diagnostico")
oView:EnableTitleView("VIEWZB3","Manutencao de Comissao")


return oView


