# pyright: reportUndefinedVariable=none
name = "opencv"

version = "4.5.5"

build_requires = [
    "cmake-3.15+<4",
    "python-3.7",
    "numpy-1.21"
]

variants = [
    ["platform-linux"]
]

@late()
def requires():
    # If we have python in the request we must also require numpy
    if in_context() and "python" in request:
        return [
            "python-3.7+<4",
            "numpy-1.21+<2"
        ]
    return []

build_command = "make -f {root}/Makefile {install}"

def commands():
    env.LD_LIBRARY_PATH.append("{root}/lib64")

    if "python" in resolve:
        env.PYTHONPATH.append("{root}/lib/python-{resolve.python.version.major}")

    if building:
        env.OpenCV_ROOT="{root}" # CMake Hint
        env.CMAKE_MODULE_PATH.prepend("{root}/cmake")
