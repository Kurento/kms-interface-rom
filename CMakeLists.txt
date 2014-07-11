cmake_minimum_required(VERSION 2.8)

set (PROJECT_NAME "kms-interface-rom")

project ("kms-interface-rom")

message (STATUS "If Kurento helpers is not found, you may install kms-cmake-utils package")
find_package(KurentoHelpers REQUIRED)

include (KurentoGitHelpers)

get_git_version (PROJECT_VERSION 4.3.2-dev)


find_program(ROM_PROCESSOR_EXEC ktool-rom-processor)

IF(NOT EXISTS ${ROM_PROCESSOR_EXEC})
	MESSAGE(FATAL_ERROR "ktool-rom-processor not found")
ENDIF(NOT EXISTS ${ROM_PROCESSOR_EXEC})

MESSAGE(STATUS "Rom processor found: ${ROM_PROCESSOR_EXEC}")

set(GEN_FILES_DIR ${CMAKE_BINARY_DIR}/rom-cpp)
set(MODEL ${CMAKE_CURRENT_SOURCE_DIR}/model.kmd.json)
set(TEMPLATES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/templates/cpp)
set(GENERATION_MARK ${CMAKE_CURRENT_BINARY_DIR}/code_generated)

execute_process(COMMAND ${ROM_PROCESSOR_EXEC} -c "${GEN_FILES_DIR}" -r ${MODEL} -t ${TEMPLATES_DIR})
execute_process(COMMAND touch ${GENERATION_MARK})

file(GLOB_RECURSE GENERATED_SOURCES ${GEN_FILES_DIR}/*cpp ${GEN_FILES_DIR}/*hpp)
file(GLOB_RECURSE TEMPLATES ${TEMPLATES_DIR}/*ftl)

add_custom_target(generate ALL DEPENDS ${GENERATION_MARK})

ADD_CUSTOM_COMMAND(
        COMMENT         "Generating source from: model.kmd.json"

        DEPENDS         ${MODEL} ${TEMPLATES}

        OUTPUT          ${GENERATION_MARK}

        COMMAND         ${ROM_PROCESSOR_EXEC}
        ARGS            -c "${GEN_FILES_DIR}" -r ${MODEL} -t ${TEMPLATES_DIR}

        COMMAND         touch
        ARGS            ${GENERATION_MARK}
)
