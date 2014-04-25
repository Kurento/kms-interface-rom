cmake_minimum_required(VERSION 2.8)

find_program(ROM_PROCESSOR_EXEC ktool-rom-processor)

IF(NOT EXISTS ${ROM_PROCESSOR_EXEC})
	MESSAGE(FATAL_ERROR "ktool-rom-processor not found")
ENDIF(NOT EXISTS ${ROM_PROCESSOR_EXEC})

MESSAGE(STATUS "Rom processor found: ${ROM_PROCESSOR_EXEC}")

if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
	execute_process(COMMAND git describe --abbrev=6 --tags --dirty --always
			OUTPUT_VARIABLE KMS_INTERFACE_VERSION
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	string(REGEX REPLACE "^kms-interface-rom-(.*)" "\\1" KMS_INTERFACE_VERSION ${KMS_INTERFACE_VERSION})
else(EXISTS "${CMAKE_SOURCE_DIR}/.git")
	set(KMS_INTERFACE_MAJOR_VERSION 4)
	set(KMS_INTERFACE_MINOR_VERSION 2)
	set(KMS_INTERFACE_PATCH_VERSION 2-dev)
	set(KMS_INTERFACE_VERSION
		${KMS_INTERFACE_MAJOR_VERSION}.${KMS_INTERFACE_MINOR_VERSION}.${KMS_INTERFACE_PATCH_VERSION})
endif(EXISTS "${CMAKE_SOURCE_DIR}/.git")

set(GEN_FILES_DIR ${CMAKE_BINARY_DIR}/rom-cpp)
set(MODEL ${CMAKE_CURRENT_SOURCE_DIR}/model.json)
set(TEMPLATES ${CMAKE_CURRENT_SOURCE_DIR}/templates/cpp)
set(GENERATION_MARK ${CMAKE_CURRENT_BINARY_DIR}/code_generated)

execute_process(COMMAND ${ROM_PROCESSOR_EXEC} -c "${GEN_FILES_DIR}" -r ${MODEL} -t ${TEMPLATES})
execute_process(COMMAND touch ${GENERATION_MARK})

file(GLOB_RECURSE GENERATED_SOURCES ${GEN_FILES_DIR}/*cpp ${GEN_FILES_DIR}/*hpp)

add_custom_target(generate ALL DEPENDS ${GENERATION_MARK})

ADD_CUSTOM_COMMAND(
        COMMENT         "Generating source from: model.json"

        DEPENDS         ${MODEL}

        OUTPUT          ${GENERATION_MARK}

        COMMAND         ${ROM_PROCESSOR_EXEC}
        ARGS            -c "${GEN_FILES_DIR}" -r ${MODEL} -t ${TEMPLATES}

        COMMAND         touch
        ARGS            ${GENERATION_MARK}
)
