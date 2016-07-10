#!/bin/bash
cargo rustdoc -- --html-in-header <(echo '<style type="text/css">.docblock>*, .collapse-toggle, #toggle-all-docs { display: none; } #core_io-show-docblock+p { display: initial }</style>')
