cmake_minimum_required(VERSION 3.16)
project(slots VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Try Qt6 first, fallback to Qt5
find_package(Qt6 COMPONENTS Core Widgets Qml Quick QUIET)
if (Qt6_FOUND)
    set(QT_VERSION_MAJOR 6)
    message(STATUS "Building with Qt6")
else()
    find_package(Qt5 5.15 REQUIRED COMPONENTS Core Widgets Qml Quick)
    set(QT_VERSION_MAJOR 5)
    message(STATUS "Building with Qt5")
endif()

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
if(QT_VERSION_MAJOR EQUAL 6 OR QT_VERSION_MAJOR EQUAL 5)
    set(RESOURCES
        resources_qt5.qrc
        images.qrc
    )
    add_compile_definitions(QT5BUILD)
else()
    set(RESOURCES
        resources.qrc
        images.qrc
    )
endif()

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
if (Qt6_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core
        Qt6::Widgets
        Qt6::Qml
        Qt6::Quick
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt5::Core
        Qt5::Widgets
        Qt5::Qml
        Qt5::Quick
    )
endif()

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
