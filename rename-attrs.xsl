<?xml version="1.0" encoding="UTF-8"?>
<!-- ~ Copyright (c) 2019. Bernard Bou <1313ou@gmail.com>. -->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dc="http://purl.org/dc/elements/1.1/">

	<xsl:strip-space elements="*" />
	<xsl:output method="xml" indent="yes" />

	<xsl:variable name="lexid_method" select="'idx'" />

	<xsl:template match="/">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="LexicalResource">
		<LexicalResource xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:ili="http://ili.org/ili/elements/1.0/">
			<xsl:apply-templates select="./Lexicon" />
		</LexicalResource>
	</xsl:template>

	<xsl:template match="Sense">
		<xsl:copy>
			<xsl:copy-of select="@*[name()!='dc:identifier']" />
			<xsl:attribute name="legacy_sensekey">
					<xsl:value-of select="@dc:identifier" />
			</xsl:attribute>
			<xsl:apply-templates select="./*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Synset">

		<xsl:copy>
			<xsl:copy-of select="@*[name()!='dc:subject' and name()!='ili']" />

			<xsl:attribute name="lexfile">
				<xsl:value-of select="@dc:subject" />
			</xsl:attribute>

			<xsl:attribute name="ili:id">
					<xsl:value-of select="@ili" />
			</xsl:attribute>

			<xsl:apply-templates select="./*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

</xsl:transform>