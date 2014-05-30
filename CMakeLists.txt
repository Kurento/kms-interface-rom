cmake_minimum_required(VERSION 2.8)

set (PROJECT_NAME "kms-interface-rom")

project (${PROJECT_NAME})

find_program(GIT_EXEC git)

SET (TAG "${PROJECT_NAME}-")

execute_process(COMMAND ${GIT_EXEC} rev-parse --git-dir OUTPUT_VARIABLE GIT_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE)

if(EXISTS ${GIT_EXEC} AND EXISTS "${GIT_DIR}")
  execute_process(COMMAND ${GIT_EXEC} submodule init WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  execute_process(COMMAND ${GIT_EXEC} submodule update WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  execute_process(COMMAND ${GIT_EXEC} remote update WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  execute_process(COMMAND ${GIT_EXEC} describe --abbrev=6 --tags --dirty --always --match "${TAG}*"
                  OUTPUT_VARIABLE PROJECT_VERSION
                  OUTPUT_STRIP_TRAILING_WHITESPACE
                  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  string(REGEX REPLACE "^${TAG}(.*)" "\\1" PROJECT_VERSION ${PROJECT_VERSION})
else()
  set(PROJECT_MAJOR_VERSION 4)
  set(PROJECT_MINOR_VERSION 3)
  set(PROJECT_PATCH_VERSION 1-dev)
  set(PROJECT_VERSION
      ${PROJECT_MAJOR_VERSION}.${PROJECT_MINOR_VERSION}.${PROJECT_PATCH_VERSION})
endif()


find_program(ROM_PROCESSOR_EXEC ktool-rom-processor)

IF(NOT EXISTS ${ROM_PROCESSOR_EXEC})
	MESSAGE(FATAL_ERROR "ktool-rom-processor not found")
ENDIF(NOT EXISTS ${ROM_PROCESSOR_EXEC})

MESSAGE(STATUS "Rom processor found: ${ROM_PROCESSOR_EXEC}")

set(GEN_FILES_DIR ${CMAKE_BINARY_DIR}/rom-cpp)
set(MODEL ${CMAKE_CURRENT_SOURCE_DIR}/model.json)
set(TEMPLATES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/templates/cpp)
set(GENERATION_MARK ${CMAKE_CURRENT_BINARY_DIR}/code_generated)

execute_process(COMMAND ${ROM_PROCESSOR_EXEC} -c "${GEN_FILES_DIR}" -r ${MODEL} -t ${TEMPLATES_DIR})
execute_process(COMMAND touch ${GENERATION_MARK})

file(GLOB_RECURSE GENERATED_SOURCES ${GEN_FILES_DIR}/*cpp ${GEN_FILES_DIR}/*hpp)
file(GLOB_RECURSE TEMPLATES ${TEMPLATES_DIR}/*ftl)

add_custom_target(generate ALL DEPENDS ${GENERATION_MARK})

ADD_CUSTOM_COMMAND(
        COMMENT         "Generating source from: model.json"

        DEPENDS         ${MODEL} ${TEMPLATES}

        OUTPUT          ${GENERATION_MARK}

        COMMAND         ${ROM_PROCESSOR_EXEC}
        ARGS            -c "${GEN_FILES_DIR}" -r ${MODEL} -t ${TEMPLATES_DIR}

        COMMAND         touch
        ARGS            ${GENERATION_MARK}
)
