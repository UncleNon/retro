extends Node

const SCHEMA_VERSION := "0.1.0"

var boot_count: int = 0


func bootstrap() -> void:
	boot_count += 1
