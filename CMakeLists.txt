cmake_minimum_required(VERSION 3.16)
project(slots VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Find Qt (tries Qt6 first, then Qt5)
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Widgets Qml Quick)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Widgets Qml Quick)
message(STATUS "Building with Qt${QT_VERSION_MAJOR}")

# Set output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Source files
set(SOURCES
    main.cpp
    gameengine.cpp
    imageprovider.cpp
)

set(HEADERS
    gameengine.h
    imageprovider.h
)

# Resource files
set(RESOURCES
    resources.qrc
    images.qrc
)

# QML files (for reference)
set(QML_FILES
    qml/slots/main.qml
    qml/slots/SlotItem.qml
    qml/slots/StartMenu.qml
    qml/slots/MyButton.qml
)

# Create executable
add_executable(${PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES}
)

# Link Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Quick
)

# Platform-specific settings
if(APPLE)
    # macOS settings (equivalent to CONFIG -= app_bundle in qmake)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE FALSE
    )
endif()

# Installation rules (optional)
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)
