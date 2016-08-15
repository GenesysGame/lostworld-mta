-- Client file for model replacing

addEventHandler( "onClientResourceStart", getRootElement(), function ( startedRes )
	if startedRes.name == "lw_models" then
		
		txd = engineLoadTXD( "data/alpha.txd" )
		dff = engineLoadDFF( "data/alpha.dff" )
		engineImportTXD( txd, 602 )
		engineReplaceModel( dff, 602 )-- replace the model at least

		txd = engineLoadTXD( "data/cheetah.txd" )
		dff = engineLoadDFF( "data/cheetah.dff" )
		engineImportTXD( txd, 415 )
		engineReplaceModel( dff, 415 )-- replace the model at least

		txd = engineLoadTXD( "data/turismo.txd" )
		dff = engineLoadDFF( "data/turismo.dff" )
		engineImportTXD( txd, 451 )
		engineReplaceModel( dff, 451 )-- replace the model at least
	end
end)