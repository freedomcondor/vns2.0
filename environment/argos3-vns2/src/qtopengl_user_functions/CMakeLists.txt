#
# Create the VNS QtOpenGL user functions library
#
add_library(vns_qtopengl_user_functions MODULE
  vns_qtopengl_user_functions.h
  vns_qtopengl_user_functions.cpp)

target_link_libraries(vns_qtopengl_user_functions
  ${SROCS_ENTITIES_LIBRARY}
  ${ARGOS_QTOPENGL_LIBRARY})
