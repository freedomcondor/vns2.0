vim coding.sh -c "
	tabnew testing/Move/vns.argos
	tabnew testing/Move/drone.lua
	tabnew testing/Move/pipuck.lua

	tabnew RobotAPI/droneAPI.lua
	vsp RobotAPI/pipuckAPI.lua
	tabnew RobotAPI/commonAPI.lua

	tabnew VNS/Driver.lua
"
<<COMMENT
	tabnew testing/Connector/vns.argos
	tabnew testing/Connector/drone.lua
	tabnew testing/Connector/pipuck.lua

	tabnew VNS/VNS.lua

	tabnew VNS/Connector.lua
	tabnew VNS/DroneConnector.lua
	vsp VNS/PipuckConnector.lua
	
	tabnew VNS/Rebellion.lua

COMMENT
