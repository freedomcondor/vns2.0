set(simu_include_dirs 
	${simu_include_dirs}
	${CMAKE_CURRENT_SOURCE_DIR}
	PARENT_SCOPE
)

set(simu_cpps
	${simu_cpps}
	${CMAKE_CURRENT_SOURCE_DIR}/Vector3.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Matrix3.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Quaternion.cpp
	PARENT_SCOPE
)
