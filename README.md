# Tarantool map-reduce (merger) module for versions 1.x and 2.x


## Prerequisites

Sources of Tarantool 1.10+ or 2.x+ available with `build` directory populated.

## Usage

* Checkout `tarantool` sources elsewhere, then build it more or less 
  the usual way

    ```bash
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
             -DENABLE_BUNDLED_LIBCURL=OFF \
             -DENABLE_DIST=ON -DCMAKE_INSTALL_PREFIX=$HOME/share
    make -j
    make module_api install
    ...
    ```

* Build and install rock locally

    ```bash
    tarantoolctl rocks make --local TARANTOOL_BUILD_INCDIR=../tarantoolm/build
    ```
    
   Where `TARANTOOL_BUILD_INCDIR` is the build directory inside of checked
   out Tarantool sources with `build` directory prepared (see step above)


Sorry! If it's looking too raw for you at the moment - we will try to simplify 
it the next time

## Examples


