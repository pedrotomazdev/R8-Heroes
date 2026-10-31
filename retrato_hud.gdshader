shader_type canvas_item;

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	// Recorte duro preserva o pixel e remove a névoa residual da geração.
	if (pixel.a < 0.95) { discard; }
	// UV usa a folha inteira: converte para o quadro local (3 colunas x 5 linhas).
	vec2 local_uv = fract(UV * vec2(3.0, 5.0));
	// Sprite de 153.6px, centro 7px acima do círculo. Só recorta o busto:
	// cabelo e cabeça podem ultrapassar livremente a borda superior.
	vec2 no_circulo = (local_uv - vec2(0.5)) * 153.6 + vec2(0.0, -7.0);
	if (no_circulo.y > 0.0 && length(no_circulo) > 55.0) { discard; }
	COLOR = vec4(pixel.rgb, 1.0);
}
