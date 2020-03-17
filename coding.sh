vim coding.sh -c "
	tabnew RobotAPI/droneAPI.lua
	vsp RobotAPI/pipuckAPI.lua
	tabnew RobotAPI/commonAPI.lua

	tabnew testing/Obstacle/vns.argos
	tabnew testing/Obstacle/drone.lua
	tabnew testing/Obstacle/builderbot.lua

	tabnew VNS/VNS.lua

	tabnew VNS/Driver.lua
	vsp VNS/Connector.lua

	tabnew VNS/Assigner.lua

	tabnew VNS/Allocator.lua
	tabnew VNS/ScaleManager.lua
"
<<COMMENT
	tabnew testing/BuilderBot/vns.argos
	tabnew testing/BuilderBot/drone.lua
	tabnew testing/BuilderBot/builderbot.lua

	tabnew testing/Allocate/vns.argos
	tabnew testing/Allocate/drone.lua
	tabnew testing/Allocate/pipuck.lua

	tabnew testing/ScaleManager/vns.argos
	tabnew testing/ScaleManager/drone.lua
	tabnew testing/ScaleManager/pipuck.lua

	tabnew testing/Assign/vns.argos
	tabnew testing/Assign/drone.lua
	tabnew testing/Assign/pipuck.lua

	tabnew testing/Move/vns.argos
	tabnew testing/Move/drone.lua
	tabnew testing/Move/pipuck.lua

	tabnew testing/Connector/vns.argos
	tabnew testing/Connector/drone.lua
	tabnew testing/Connector/pipuck.lua


	tabnew VNS/DroneConnector.lua
	vsp VNS/PipuckConnector.lua
	
	tabnew VNS/Rebellion.lua

COMMENT
