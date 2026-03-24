/**
 * Custom highlight.js grammar for GDScript.
 * Covers the subset of GDScript used in the tutorial.
 */
module.exports = function (hljs) {
  var KEYWORDS = {
    keyword:
      "if elif else for while match return break continue pass " +
      "func class extends class_name signal var const enum " +
      "static await yield in is as not and or " +
      "true false null self super",
    built_in:
      "print push_error push_warning load preload " +
      "abs ceil floor round clamp lerp min max sign " +
      "randi randf randi_range randf_range " +
      "str int float bool " +
      "is_instance_valid weakref " +
      "linear_to_db db_to_linear",
    type:
      "String int float bool void " +
      "Vector2 Vector2i Vector3 Vector3i Rect2 Color " +
      "Array Dictionary " +
      "Node Node2D Node3D Control " +
      "Sprite2D AnimatedSprite2D " +
      "CharacterBody2D RigidBody2D StaticBody2D Area2D " +
      "CollisionShape2D RayCast2D " +
      "Camera2D " +
      "TileMapLayer TileSet " +
      "AudioStreamPlayer AudioStreamPlayer2D " +
      "Label RichTextLabel Button HSlider VBoxContainer HBoxContainer " +
      "PanelContainer MarginContainer GridContainer CenterContainer " +
      "CanvasLayer ColorRect TextureRect " +
      "Resource PackedScene SceneTree Tween Timer " +
      "InputEvent InputEventKey " +
      "FileAccess DirAccess JSON Time " +
      "AudioStream AudioServer " +
      "Marker2D",
    literal: "true false null INF NAN PI TAU",
  };

  var ANNOTATIONS = {
    className: "meta",
    begin: "@",
    end: "\\b",
    contains: [
      {
        className: "keyword",
        begin:
          "export|onready|icon|tool|export_file|export_range|export_enum|export_multiline",
      },
    ],
  };

  var STRING = {
    className: "string",
    variants: [
      { begin: '"""', end: '"""' },
      { begin: "'''", end: "'''" },
      { begin: '"', end: '"', illegal: "\\n" },
      { begin: "'", end: "'", illegal: "\\n" },
      { begin: '&"', end: '"' },
      { begin: "\\^\"", end: '"' },
    ],
  };

  var NUMBER = {
    className: "number",
    variants: [
      { begin: "0x[0-9a-fA-F_]+" },
      { begin: "0b[01_]+" },
      { begin: "\\b\\d[\\d_]*\\.?[\\d_]*(?:e[+-]?\\d+)?" },
    ],
    relevance: 0,
  };

  var COMMENT = {
    className: "comment",
    variants: [{ begin: "#", end: "$" }],
    contains: [
      {
        className: "doctag",
        begin: "(?:TODO|FIXME|NOTE|HACK|XXX):",
      },
    ],
  };

  var FUNC = {
    className: "function",
    beginKeywords: "func",
    end: ":",
    excludeEnd: true,
    contains: [
      {
        className: "title",
        begin: "[a-zA-Z_][a-zA-Z0-9_]*",
      },
      {
        className: "params",
        begin: "\\(",
        end: "\\)",
        contains: [STRING, NUMBER, ANNOTATIONS],
      },
      {
        className: "type",
        begin: "->\\s*",
        end: ":",
        excludeEnd: true,
      },
    ],
  };

  var CLASS = {
    className: "class",
    beginKeywords: "class",
    end: ":",
    excludeEnd: true,
    contains: [
      {
        className: "title",
        begin: "[A-Z][a-zA-Z0-9_]*",
      },
    ],
  };

  var SIGNAL = {
    className: "keyword",
    begin: "\\bsignal\\b",
  };

  return {
    name: "GDScript",
    aliases: ["gdscript", "gd"],
    keywords: KEYWORDS,
    contains: [
      COMMENT,
      STRING,
      NUMBER,
      ANNOTATIONS,
      FUNC,
      CLASS,
      SIGNAL,
      {
        className: "variable",
        begin: "\\$[a-zA-Z_/%][a-zA-Z0-9_/%]*",
      },
      {
        className: "variable",
        begin: "%[a-zA-Z_][a-zA-Z0-9_]*",
      },
    ],
  };
};
