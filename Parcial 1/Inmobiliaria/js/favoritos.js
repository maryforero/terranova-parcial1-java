// TerraNova Bienes Raíces - alternar favoritos sin recargar la página.
// Antes esto era un enlace a favoritos/alternar.jsp que recargaba toda la
// página (perdiendo la posición del scroll). Ahora se llama por AJAX a
// favoritos/alternarAjax.jsp y solo se actualiza el botón en el sitio.
(function () {
    "use strict";

    function mostrarToast(mensaje, icono) {
        var contenedor = document.getElementById("toast-favoritos");
        if (!contenedor) {
            contenedor = document.createElement("div");
            contenedor.id = "toast-favoritos";
            contenedor.className = "toast-favoritos-contenedor";
            document.body.appendChild(contenedor);
        }
        var aviso = document.createElement("div");
        aviso.className = "toast-favoritos alerta-flotante";
        aviso.innerHTML = '<i class="bi ' + icono + '"></i> ' + mensaje;
        contenedor.appendChild(aviso);
        setTimeout(function () {
            aviso.classList.add("toast-favoritos-salir");
            setTimeout(function () { aviso.remove(); }, 250);
        }, 1800);
    }

    function alternar(idPropiedad, ctxBase, callback) {
        fetch(ctxBase + "/favoritos/alternarAjax.jsp?idPropiedad=" + encodeURIComponent(idPropiedad), {
            method: "GET",
            credentials: "same-origin"
        })
        .then(function (resp) { return resp.text(); })
        .then(function (texto) { callback(texto.trim()); })
        .catch(function () { callback("ERROR"); });
    }

    document.addEventListener("DOMContentLoaded", function () {
        var ctxBase = document.body.getAttribute("data-ctx") || "";

        // Botón flotante (corazón) sobre las tarjetas de inicio/catálogo.
        document.querySelectorAll(".btn-favorito-card").forEach(function (boton) {
            boton.addEventListener("click", function (evento) {
                evento.preventDefault();
                var id = boton.getAttribute("data-id");
                alternar(id, ctxBase, function (resultado) {
                    if (resultado === "AGREGADO") {
                        boton.classList.add("es-favorito");
                        boton.querySelector("i").className = "bi bi-heart-fill";
                        boton.title = "Quitar de favoritos";
                        mostrarToast("Se agregó a tus favoritos", "bi-heart-fill");
                    } else if (resultado === "QUITADO") {
                        boton.classList.remove("es-favorito");
                        boton.querySelector("i").className = "bi bi-heart";
                        boton.title = "Agregar a favoritos";
                        mostrarToast("Se quitó de tus favoritos", "bi-heartbreak");
                    }
                });
            });
        });

        // Botón grande de la ficha de detalle (con texto).
        document.querySelectorAll(".btn-favorito-detalle").forEach(function (boton) {
            boton.addEventListener("click", function (evento) {
                evento.preventDefault();
                var id = boton.getAttribute("data-id");
                alternar(id, ctxBase, function (resultado) {
                    var icono = boton.querySelector("i");
                    if (resultado === "AGREGADO") {
                        boton.classList.remove("btn-outline-danger");
                        boton.classList.add("btn-danger");
                        icono.className = "bi bi-heart-fill";
                        boton.lastChild.textContent = " Quitar de favoritos";
                        mostrarToast("Se agregó a tus favoritos", "bi-heart-fill");
                    } else if (resultado === "QUITADO") {
                        boton.classList.add("btn-outline-danger");
                        boton.classList.remove("btn-danger");
                        icono.className = "bi bi-heart";
                        boton.lastChild.textContent = " Agregar a favoritos";
                        mostrarToast("Se quitó de tus favoritos", "bi-heartbreak");
                    }
                });
            });
        });

        // Botón "quitar" en la página Mis favoritos: elimina la tarjeta completa.
        document.querySelectorAll(".btn-quitar-favorito").forEach(function (boton) {
            boton.addEventListener("click", function (evento) {
                evento.preventDefault();
                var id = boton.getAttribute("data-id");
                var tarjeta = boton.closest(".col-favorito");
                alternar(id, ctxBase, function (resultado) {
                    if (resultado === "QUITADO" && tarjeta) {
                        tarjeta.style.transition = "opacity 0.25s ease";
                        tarjeta.style.opacity = "0";
                        setTimeout(function () {
                            tarjeta.remove();
                            if (!document.querySelector(".col-favorito")) {
                                location.reload();
                            }
                        }, 250);
                        mostrarToast("Se quitó de tus favoritos", "bi-heartbreak");
                    }
                });
            });
        });
    });
})();
