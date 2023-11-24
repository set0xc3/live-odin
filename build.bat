@echo off

odin.exe build src -out:bin/live.exe -o:none -build-mode:exe -subsystem:console -collection:live=src -debug -show-timings
