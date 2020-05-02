add_library(vns_loop_functions MODULE
   vns_loop_functions.h
   vns_loop_functions.cpp)

target_link_libraries(vns_loop_functions
   ${SROCS_ENTITIES_LIBRARY})

