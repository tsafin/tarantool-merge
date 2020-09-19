# Tarantool map-reduce (merger) module for versions 1.x and 2.x


## Prerequisites

Sources of Tarantool 1.10+ or 2.x+ available with `build` directory populated.

## Usage

* Checkout `tarantool` sources with extended `module_api` elsewhere then build it more or less the usual way

    ```bash
    cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
             -DENABLE_BUNDLED_LIBCURL=OFF \
             -DENABLE_DIST=ON -DCMAKE_INSTALL_PREFIX=$HOME/share
    make -j install
    ...
    ```

* Build and install rock locally

    ```bash
    tarantoolctl rocks make TARANTOOL_DIR=$HOME/share/
    ```
    
   Where `TARANTOOL_DIR` is the installation directory where module_api was installed (by default it would be `/usr/share` 
   for `tarantool` package).


Sorry! If it's looking too raw for you at the moment - we will try to simplify 
it the next time

## Examples

```
$HOME/share/bin/tarantool examples/merger-test.lua
```
