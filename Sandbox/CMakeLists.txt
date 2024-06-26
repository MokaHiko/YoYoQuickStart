cmake_minimum_required(VERSION 3.21.0)
project(Sandbox VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

add_executable(${PROJECT_NAME}
	src/CameraController.h
	src/CameraController.cpp

	src/Sandbox.h
	src/Sandbox.cpp
)

# if(CMAKE_BUILD_TYPE AND CMAKE_BUILD_TYPE STREQUAL "Debug" OR TRUE)
# endif()

target_include_directories(${PROJECT_NAME} PUBLIC src/  ${PHYSX_LIB_PATH}/include)
target_link_libraries(${PROJECT_NAME} PUBLIC 
	YoYo 
)

add_custom_target(copy_assets ALL
	COMMAND ${CMAKE_COMMAND} -E copy_directory
	${PROJECT_SOURCE_DIR}/assets
	${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/assets
	COMMENT "Copying resources into bin and binary folder."
	COMMAND cmd /c ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/assets/shaders/compile_shaders.bat
	COMMENT "Compiling shaders.")

set_target_properties(
	${PROJECT_NAME} PROPERTIES
	VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

add_dependencies(${PROJECT_NAME} copy_assets)