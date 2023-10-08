#!/bin/bash

flutter build web --base-href /ClueIn/ --release
cp -r build/web/* docs/