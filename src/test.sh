#!/bin/bash
cairo-compile p256_example.cairo --output p256.json &&
cairo-run --program p256.json --print_output --layout all