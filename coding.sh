vim coding.sh -c "
	tabnew VNS/VNS.lua

	tabnew testing/Allocate/vns.argos
	tabnew testing/Allocate/drone.lua
	tabnew testing/Allocate/pipuck.lua

	tabnew VNS/Driver.lua
	vsp VNS/Connector.lua

	tabnew VNS/Assigner.lua

	tabnew VNS/Allocator.lua
"
<<COMMENT
	tabnew testing/Move/vns.argos
	tabnew testing/Move/drone.lua
	tabnew testing/Move/pipuck.lua

	tabnew testing/Connector/vns.argos
	tabnew testing/Connector/drone.lua
	tabnew testing/Connector/pipuck.lua

	tabnew testing/Assign/vns.argos
	tabnew testing/Assign/drone.lua
	tabnew testing/Assign/pipuck.lua

	tabnew RobotAPI/droneAPI.lua
	vsp RobotAPI/pipuckAPI.lua
	tabnew RobotAPI/commonAPI.lua

	tabnew VNS/DroneConnector.lua
	vsp VNS/PipuckConnector.lua
	
	tabnew VNS/Rebellion.lua

COMMENT
