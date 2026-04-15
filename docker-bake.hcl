variable "PUBLISH" {
    default = false
}

variable "VERSION" {
    default = "0"
}

variable "IMAGE" {
    default = PUBLISH ? "docker.io/nextgis/nextgisweb-ce" : "nextgisweb-ce"
}

variable "TAG" {
    default = "latest"
}

target "main" {
    context    = "build"
    dockerfile = "Dockerfile"
    tags       = ["${IMAGE}:${TAG}"]
    output     = PUBLISH ? ["type=registry"] : ["type=docker"]

    args = {
        CRATER_DISTRIBUTION_VERSION = VERSION,
        CRATER_DISTRIBUTION_DATE = formatdate("YYYY-MM-DD", timestamp()),
    }
}

group "default" {
    targets = ["main"]
}