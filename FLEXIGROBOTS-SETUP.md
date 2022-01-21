0. Build cube-in-a-box image
	
	$ cd cube-in-a-box
	$ docker build . --tag opendatacube/cube-in-a-box
	

1. Registration of EO data products definitions and indexation of Sentinel 2 data products

	$ cd datacube-config
	$ docker-compose -f docker-compose.products.yaml up
	$ docker exec -it datacube-config_products-tester_1 bash
	# datacube -v system init
	# dc-sync-products /conf/products_prod.csv
	# stac-to-dc --bbox='-10,41,-9,42' --catalog-href='https://earth-search.aws.element84.com/v0/' --collections='sentinel-s2-l2a-cogs' --datetime='2021-01-01/2022-01-31'
	# exit


2. Expose ODC EO data products via OGC Services

	$ cd datacube-config
	$ docker-compose -f docker-compose.ows.yaml up
	$ docker exec -it datacube-config_ows_1 bash
	# datacube-ows-update --schema --role postgres
	# datacube-ows-update --views
	# datacube-ows-update
	# exit
	
	
3. Deploy Jupyter Hub and sample notebooks
	
	$ cd datacube-config
    $ docker-compose -f docker-compose.jupyter.yaml up