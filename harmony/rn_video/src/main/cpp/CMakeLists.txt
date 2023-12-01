cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

file(GLOB rnoh_video_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_video SHARED ${rnoh_video_SRC})
target_include_directories(rnoh_video PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(rnoh_video PUBLIC rnoh)