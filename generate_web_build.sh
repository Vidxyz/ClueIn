#!/bin/bash

flutter build web --base-href /ClueIn/ --release
cp -r build/web/* docs/

# Note - push to origin to trigger github action to trigger deploy