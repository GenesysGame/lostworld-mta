-- Client file for textrues and models replacing

function retexture( anObject, texture, textureName )
	local shader = dxCreateShader('replace.fx')
	dxSetShaderValue(shader, "Tex0", texture)
	engineApplyShaderToWorldTexture(shader, textureName, anObject)
end