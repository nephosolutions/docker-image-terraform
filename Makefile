#   Copyright 2017 Sebastian Trebitz
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

.PHONY: build clean

build:
	docker build -t strebitz/terraform .

workspace/docker-image_strebitz-terraform.tar.gz: build workspace
	docker save strebitz/terraform | gzip -c > workspace/docker-image_strebitz-terraform.tar.gz

clean:
	$(if $(wildcard workspace),rm -rf workspace)

workspace:
	mkdir -p workspace
