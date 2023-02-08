#include 'Totvs.ch'
#Include 'FwMvcDef.ch'


 //=====================================================
     /*
	 Função responsável por criar o Brose e retorná-lo para o Menu que invocá-lo
    Quando eu tenho uma Static Function BrowseDef no meu fonte, significa
    que eu posso emprestá-la para outros fontes, através do FwLoadBr
    @type  Function
     */
 //=======================================================


User Function MVCZ2Z3()
	//local oBrowse  := FwLoadBrw("MVCZ2Z3") //Digo o fonte que eu eestou buscado, o BrowseDef
	Local oBrowse  := FwMBrowse():New()

	oBrowse:SetDescription("Cadastro de chamados")
	oBrowse:SetAlias("SZ2")

	oBrowse:Activate()
Return

//MenuDef - sera criado por ultimo
Static Function MenuDef()
	Local aMenu     := {}

	//Trago atraves da FwMvcMenu, o Menu para o array aMenuAut
	//Local aMenuAut      := FwMvcMenu("MVCSZ2SZ3")

            /*
           Adiciono dentro da varaivel aMenu, o titulo Legenda e Sobre, Junto com a açao
           de chamar as UserFunctions de Legenda e Sobre, essas operaçoes sao de codigo 6 e
           eu passo o nivel de usuario 0
           */
	ADD OPTION aMenu TITLE 'Legenda'      ACTION 'U_SZ2LEG'           OPERATION 6 ACCESS 0
	ADD OPTION aMenu TITLE 'Sobre'        ACTION 'u_SZ2SOBRE'         OPERATION 6 ACCESS 0
	ADD OPTION aMenu TITLE 'Incluir'      ACTION 'VIEWDEF.MVCZ2Z3'    OPERATION 3 ACCESS 0
	ADD OPTION aMenu TITLE 'Alterar'      ACTION 'VIEWDEF.MVCZ2Z3'    OPERATION 4 ACCESS 0
	ADD OPTION aMenu TITLE 'Visualizar'   ACTION 'VIEWDEF.MVCZ2Z3'    OPERATION 2 ACCESS 0
	ADD OPTION aMenu TITLE 'Excluir'      ACTION 'VIEWDEF.MVCZ2Z3'    OPERATION 5 ACCESS 0


return aMenu

//=====================================================

   // Funçao ModelDef

//===============================================================

Static Function ModelDef()
//Declaro o meu modelo de dados sem passar blocos de validaçao pois usaremos a validaçao
	Local oModel   := MPFormModel():New("MVCZ2Z3M",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)

	//Crio as estruturas das tabelas PAI (SZ2) e FILHO(SZ3)
	local oStPaiZ2   :=  FwFormStruct(1, "SZ2")
	Local oStFilhoZ3 :=  FwFormStruct(1, "SZ3")

	//Após declarar a estrutura de dados, eu posso modificar o campo com SetProperty
	oStFilhoZ3:SetProperty("Z3_CHAMADO",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "SZ2->Z2_COD"))

	//Crio os modelos de Cabeçalho e Item
	oModel:AddFields("SZ2MASTER",, oStPaiZ2)
	oModel:AddGrid("SZ3DETAIL","SZ2MASTER", oStFilhoZ3,,,,,)//Essas virgulas em branco, sao blocos da validaçao

	//O meu grid, irá se relacionar com o cabeçalho, através dos campos FILIAL e CODIGO DE CHAMADO
	oModel:SetRelation("SZ3DETAIL",{{"Z3_FILIAL", "xFilial('SZ2')"},{"Z3_CHAMADO", "Z2_COD"}}, SZ3->(IndexKey(1)))

	//Setamos a chave Primnaria, Prevalece o que esta na SX2(X2UNICO), se na X2 estiver preenchido
	//Nao podemos ter entro de uma chamado, dois comentario com o mesmo codigo
	oModel:SetPrimaryKey({"Z3_FILIAL", "Z3_CHAMADO", "Z3_CODIGO"})

	//oModel:GetModel("SZ3DETAIL"):SetUniqueline({"Z3_CHAMADO","Z3_CODIGO"})

	oModel:SetDescription("Modelo 3 - Sistema de chamados")
	oModel:GetModel("SZ2MASTER"):SetDescription("CABEÇALHO DO CHAMADO")
	oModel:GetModel("SZ3DETAIL"):SetDescription("COMENTARIOS DO CHAMADO")

    
return oModel


//==========================================================

        //Funçao ViewDef

//=======================================================================


Static Function ViewDef()
	Local oView

	//Invoco o model da funçao que quero
	Local oModel       := FwLoadModel("MVCZ2Z3")

               /*
    A grande diferença das estruturas de dados do modelo 2 para o modelo 3, é que no modelo 2
    a estrutura de dados do cabeçalho é temporária/imaginária/fictícia, jáaaaaaaaa no modelo 3/x
    todas as estruturas de dados, tendem à ser REAIS, ou seja, importamos via FwFormStruct, a(s) tabela(s)
    propriamente ditas
               */ 
	Local oStPaiZ2     := FwFormStruct(2, "SZ2")
	Local oStFilhoZ3   := FwFormStruct(2, "SZ3")

	oStFilhoZ3:RemoveField("Z3_CHAMADO")

	oStFilhoZ3:SetProperty("Z3_CODIGO", MVC_VIEW_CANCHANGE, .F.)

	//Faço a instancia da funçao FwFormView para a variavel oView
	oView  := FwFormView():New()

	//Carrego o model importado para a View
	oView:SetModel(oModel)

	//Crio as views de cabeçalho e item, com as estruturas de dados criados acima
	oView:AddField("VIEWSZ2", oStPaiZ2, "SZ2MASTER")
	oView:AddGrid("VIEWSZ3", oStFilhoZ3, "SZ3DETAIL")

	//faço o campo de item ficar incremental
	oView:AddIncrementField("SZ3DETAIL","Z3_CODIGO")

	//Criamos os BOX horizontais para CABEÇALHO E ITENS
	oView:CreateHorizontalBox("CABEC",60)
	oView:CreateHorizontalBox("GRID",40)

	//Amarro a minha view aos BOX criados
	oView:SetOwnerView("VIEWSZ2","CABEC")
	oView:SetOwnerView("VIEWSZ3","GRID")

	//Darei titulos personalizados e comentario do chamado
	oView:EnableTitleView("VIEWSZ2", "Detalhes do Chamado/Cabeçalho")
	oView:EnableTitleView("VIEWSZ3", "Comentarios do Chamado/Itens")


return oView

//----------------------------------------------------

      // Funçao Legenda

//---------------------------------------------------------------

User Function SZ2LEG()
	Local aLegenda  := {}

	aAdd(aLegenda,{"BR_VERDE",    "Chamado aberto"})
	aAdd(aLegenda,{"BR_AMARELO",  "Chamado em andamento"})
	aAdd(aLegenda,{"BR_VERMELHO", "Chamado Finalizado"})

	BrwLegenda("Status dos chamados",,aLegenda)
return aLegenda

//----------------------------------------------------

      //Funçao Sobre

//-------------------------------------------------------------

User Function SZ2Sobre()
	Local cSobre

	cSobre := " -<br> Mimha primeira em MVC Modelo 3 <br>" + ;
		"Esse Sistema de chamados foi desenvolvido por um estudante de Protheus da Sistematizei."

	MsgInfo(cSobre," Sobre o Programador...")


return


