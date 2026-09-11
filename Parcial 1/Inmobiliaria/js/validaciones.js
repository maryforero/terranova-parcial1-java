// TerraNova Bienes Raices - validaciones de formulario en el navegador.
// Complementan (NO reemplazan) la validacion obligatoria del servidor.
(function () {
    "use strict";

    function marcarInvalido(campo, mensaje) {
        campo.classList.add("is-invalid");
        var feedback = campo.parentElement.querySelector(".invalid-feedback");
        if (feedback) feedback.textContent = mensaje;
    }

    function limpiar(campo) {
        campo.classList.remove("is-invalid");
    }

    document.addEventListener("DOMContentLoaded", function () {
        document.querySelectorAll("form[data-validar]").forEach(function (form) {
            form.addEventListener("submit", function (evento) {
                var valido = true;

                form.querySelectorAll("[required]").forEach(function (campo) {
                    if (!campo.value || !campo.value.trim()) {
                        marcarInvalido(campo, "Este campo es obligatorio.");
                        valido = false;
                    } else {
                        limpiar(campo);
                    }
                });

                form.querySelectorAll('input[type="email"]').forEach(function (campo) {
                    var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (campo.value && !re.test(campo.value)) {
                        marcarInvalido(campo, "Correo electronico no valido.");
                        valido = false;
                    }
                });

                form.querySelectorAll('input[data-tipo="telefono"]').forEach(function (campo) {
                    var re = /^[0-9+()\-\s]{7,20}$/;
                    if (campo.value && !re.test(campo.value)) {
                        marcarInvalido(campo, "Telefono no valido.");
                        valido = false;
                    }
                });

                form.querySelectorAll('input[data-tipo="precio"]').forEach(function (campo) {
                    var valor = parseFloat(campo.value);
                    if (isNaN(valor) || valor <= 0) {
                        marcarInvalido(campo, "Ingrese un precio mayor a cero.");
                        valido = false;
                    }
                });

                if (!valido) {
                    evento.preventDefault();
                    evento.stopPropagation();
                }
            });
        });
    });
})();
