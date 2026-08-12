#!/usr/bin/env bash

hyprlock &
pid=$!

sleep 0.2
wait $pid

for i in {1..3}; do
    hyprlock &
    sleep 0.05
    killall hyprlock
done
