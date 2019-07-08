-- à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
-- á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
-- â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
-- ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
-- ä : \195\164                    ñ : \195\177    ö : \195\182
-- æ : \195\166                                    ø : \195\184
-- ç : \195\167                                    œ : \197\147
-- Ä : \195\132    Ö : \195\150    Ü : \195\156    ß : \195\159

local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")

if GetLocale() == "ptBR" then
	L["Select all"] = "Selecionar todos"
	L["Remove all"] = "Remover todos"

	L["Enable AutoLooter"] = "Ativar AutoLooter"
	L["Printout items looted"] = "Escrever loot"
	L["Printout items ignored"] = "Escrever ignorados"
	L["Printout items type"] = "Escrever o tipo"
	L["Loot everything"] = "Pegar tudo"
	L["Loot quest itens"] = "Pegar itens de missão"
	L["Close after loot"] = "Fechar após pegar"
	L["Ignore greys when looting by type"] = "Ignorar cinzas ao pegar por tipo"
	L["Auto confirm loot roll"] = "Auto confirmar loot"

	L["Close"] = "Fechar"
	L["Price (in coppers)"] = "Preço (em bronze)"
	L["Rarity"] = "Raridade"
	L["Locked"] = "Bloqueado"

	L["Coin"] = "Moeda"
	L["Listed"] = "Lista"
	L["Rarity"] = "Raridade"
	L["Price"] = "Preço"
	L["All"] = "Tudo"
	L["Quest"] = "Missão"
	L["Ignored"] = "Ignorado"
	L["Type"] = "Tipo"
	L["Token"] = "Moeda"

	L["(Legacy Types)"] = "(Tipos Legados)"

	L["Enabled"] = "Ligado"
	L["Disabled"] = "Desligado"
	L["On"] = "Ligado"
	L["Off"] = "Desligado"

	L["Loot by Price"] = "Loot por preço"
	L["Loot by Rarity"] = "Loot por raridade"

	L["Add item to white list"] = "Adiciona um item na lista branca"
	L["Add item to ignore list"] = "Adiciona um item na lista de ignorados"
	L["Add item to alert list"] = "Adiciona um item na lista de alertas"
	L["Remove item from white list"] = "Remove um item da lista branca"
	L["Remove item from ignore list"] = "Remove um item da lista de ignorados"
	L["Remove item from alert list"] = "Remove um item da lista de alertas"

	L["Set alert sound"] = "Altera o som de alerta"

	L["Invalid item"] = "Item inválido"

	L["Already in the list"] = "Já está na lista"
	L["Added"] = "Adicionado"

	L["Removed"] = "Removido"
	L["Not listed"] = "Não listado"

	L["Left-click"] = "Clique-esquerdo"
	L["Right-click"] = "Clique-direito"

	L["to Show/Hide UI"] = "para Mostrar/Esconder a UI"
	L["Show/Hide UI"] = "Mostra/Esconde a UI"
	L["Show/Hide minimap button"] = "Mostra/Esconde botão do minimapa"
	L["to Enable/Disable loot all"] = "para Liga/Desligar 'pegar tudo'"
	L["Hold and drag to move"] = "Segure e arraste para mover"

	L["Ignore BoP"] = "Ignorar BoP"

	L["General"] = "Geral"
end