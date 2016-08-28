-- Client file for textrues and models replacing

function retexture( anObject, texture, textureName )
	local shader = nil
	if anObject.type == "ped" or anObject.type == "player" then
		shader = dxCreateShader('replace.fx', 0, 0, false, "ped")
	else 
		shader = dxCreateShader('replace.fx')
	end
	dxSetShaderValue(shader, "Tex0", texture)
	engineApplyShaderToWorldTexture(shader, textureName, anObject)
end