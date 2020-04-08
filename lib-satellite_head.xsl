<?xml version="1.0" encoding="UTF-8"?>
<!-- ~ Copyright (c) 2019. Bernard Bou <1313ou@gmail.com>. -->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dc="http://purl.org/dc/elements/1.1/">

	<!-- not necessary imported as global by caller -->
	<!-- <xsl:import href='lib-lexid.xsl' /> -->
	<!-- <xsl:import href='lib-satellite_head_word.xsl' /> -->

	<xsl:variable name='debug' select='true()' />
	<xsl:variable name='error' select='true()' />

	<xsl:template name="make-satellite-head-sense">
		<xsl:param name="sensenode" />
		<xsl:param name="pos" />

		<xsl:if test='$debug = true()'>
			<xsl:message>
				<xsl:text>[D] CALLED make-satellite-head-sense(sensenode_id=</xsl:text>
				<xsl:value-of select="$sensenode/@id" />
				<xsl:text>, pos=</xsl:text>
				<xsl:value-of select="$pos" />
				<xsl:text>)</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$pos != 's'">
				<xsl:message>
					<xsl:text>[D]   not a satellite</xsl:text>
					<xsl:text>&#xa;</xsl:text>
				</xsl:message>
				<xsl:value-of select="''" />
			</xsl:when>

			<xsl:otherwise>
				<xsl:variable name="synset_id" select="$sensenode/@synset" />
				<xsl:variable name="synset" select="id($synset_id)" />
				<xsl:variable name="head_synset_id" select="$synset[1]/SynsetRelation[@relType='similar']/@target" />
				<xsl:variable name="head_senses" select="//Sense[@synset=$head_synset_id]" />

				<xsl:if test='$debug = true()'>
					<xsl:message>
						<xsl:text>[D]   synset_id </xsl:text>
						<xsl:value-of select="$synset_id" />
						<xsl:text>&#xa;[D]   its fetched synset definition '</xsl:text>
						<xsl:value-of select="$synset" />
						<xsl:text>'</xsl:text>
						<xsl:text>&#xa;[D]   its fetched synset count() </xsl:text>
						<xsl:value-of select="count($synset)" />
						<xsl:text>&#xa;[D]   its fetched synset/@id </xsl:text>
						<xsl:value-of select="$synset/@id" />
						<xsl:text>&#xa;[D]   head_synset_id (through similar) </xsl:text>
						<xsl:value-of select="$head_synset_id" />
						<xsl:text>&#xa;[D]   head_senses </xsl:text>
						<xsl:value-of select="count($head_senses)" />
						<xsl:for-each select="$head_senses">
							<xsl:text>&#xa;[D]   -head_sense </xsl:text>
							<xsl:value-of select="./@id" />
						</xsl:for-each>
					</xsl:message>
				</xsl:if>

				<xsl:if test="count($head_senses) = 0 and $error">
					<xsl:message>
						<xsl:text>[E]   not head sense found for '</xsl:text>
						<xsl:value-of select="$sensenode/@id" />
						<xsl:text>' head synset is '</xsl:text>
						<xsl:value-of select="$head_synset_id" />
						<xsl:text>'</xsl:text>
					</xsl:message>
				</xsl:if>

				<!-- HEAD SENSE : "the sense which has an antonymy relation" /> -->
				<xsl:variable name="head_sense_with_antonym" select="$head_senses[SenseRelation/@relType = 'antonym']" />
				<xsl:if test="$debug">
					<xsl:message>
						<xsl:text>[D]   has antonym </xsl:text>
						<xsl:value-of select="count($head_sense_with_antonym)" />
						<xsl:text>: </xsl:text>
						<xsl:value-of select="$head_sense_with_antonym[1]/@id" />
					</xsl:message>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="count($head_sense_with_antonym) = 1">
						<!-- return -->
						<xsl:value-of select="$head_sense_with_antonym/@id" />
					</xsl:when>
					<xsl:when test="count($head_sense_with_antonym) > 1">
						<xsl:message>
							<xsl:text>[W]   multiple antonyms found </xsl:text>
							<xsl:text> taking first of </xsl:text>
							<xsl:value-of select="count($head_sense_with_antonym)" />
							<xsl:text> head synset member(s) with antonyms </xsl:text>
						</xsl:message>
						<!-- return -->
						<xsl:value-of select="$head_sense_with_antonym[1]/@id" />
					</xsl:when>
					<xsl:otherwise>
						<!-- HEAD WORD : "the lemma of the first word of the satellite's head synset" /> -->
						<xsl:message>
							<xsl:text>[W]   no indirect antonym found </xsl:text>
							<xsl:text> taking first of </xsl:text>
							<xsl:value-of select="count($head_senses)" />
							<xsl:text> head synset member(s) </xsl:text>
						</xsl:message>
						<!-- return -->
						<xsl:value-of select="$head_senses[1]/@id" />
					</xsl:otherwise>
				</xsl:choose>

			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="make-satellite-head-word">
		<xsl:param name="sensenode" />
		<xsl:param name="pos" />

		<xsl:if test='$debug = true()'>
			<xsl:message>
				<xsl:text>[D] CALLED make-satellite-head-word(sensenode_id=</xsl:text>
				<xsl:value-of select="$sensenode/@id" />
				<xsl:text>, pos=</xsl:text>
				<xsl:value-of select="$pos" />
				<xsl:text>)</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:variable name="head_sense">
			<xsl:call-template name="make-satellite-head-sense">
				<xsl:with-param name="sensenode" select="$sensenode" />
				<xsl:with-param name="pos" select="$pos" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="lemma" select="$head_sense/../Lemma/@writtenForm" />
		<xsl:variable name="head_word" select="translate($lemma,' ','_')" />

		<xsl:if test='$debug = true()'>
			<xsl:message>
				<xsl:text>&#xa;[D]   head_sense/@id </xsl:text>
				<xsl:value-of select="$head_sense/@id" />
				<xsl:text>&#xa;[D]   lemma </xsl:text>
				<xsl:value-of select="$lemma" />
				<xsl:text>&#xa;[D]   headword=</xsl:text>
				<xsl:value-of select="$head_word" />
			</xsl:message>
		</xsl:if>
		<xsl:if test="$head_word = '' and $error = true()">
			<xsl:message>
				<xsl:text>[E]   head not found for '</xsl:text>
				<xsl:value-of select="$sensenode/@id" />
				<xsl:text>'</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:value-of select="$head_word" />

	</xsl:template>

	<!-- S A T E L L I T E - H E A D - F A C T O R Y -->

	<xsl:template name="make-satellite-head">
		<xsl:param name="sensenode" />
		<xsl:param name="pos" />
		<xsl:param name="method" />

		<xsl:if test='$debug = true()'>
			<xsl:message>
				<xsl:text>[D] CALLED make-satellite-head(sensenode_id=</xsl:text>
				<xsl:value-of select="$sensenode/@id" />
				<xsl:text>, pos=</xsl:text>
				<xsl:value-of select="$pos" />
				<xsl:text>)</xsl:text>
			</xsl:message>
		</xsl:if>

		<!-- SATELLITE HEAD -->
		<xsl:choose>
			<xsl:when test="$pos != 's'">
				<xsl:message>
					<xsl:text>[D]   not a satellite</xsl:text>
					<xsl:text>&#xa;</xsl:text>
				</xsl:message>
				<xsl:value-of select="':'" />
			</xsl:when>

			<xsl:otherwise>
				<!-- HEAD WORD : "the lemma of the first word of the satellite's head synset" /> -->
				<xsl:variable name="headsenseid">
					<xsl:call-template name='make-satellite-head-sense'>
						<xsl:with-param name='sensenode' select='$sensenode' />
						<xsl:with-param name='pos' select="$pos" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="headsense" select='id($headsenseid)' />

				<xsl:if test='$debug = true()'>
					<xsl:message>
						<xsl:text>[D]   headsenseid=</xsl:text>
						<xsl:value-of select="$headsenseid" />
					</xsl:message>
				</xsl:if>

				<xsl:variable name="lemma" select="$headsense/../Lemma/@writtenForm" />
				<xsl:variable name="headword" select="translate($lemma,' ','_')" />

				<xsl:if test='$debug = true()'>
					<xsl:message>
						<xsl:text>[D]   headword=</xsl:text>
						<xsl:value-of select="$headword" />
					</xsl:message>
				</xsl:if>

				<!-- HEAD LEXID : "a two digit decimal integer that, when appended onto head_word, uniquely identifies the sense of head_word within a lexicographer file, as
					described for lex_id" /> -->
				<xsl:variable name="headid">
					<xsl:call-template name="make-lexid">
						<xsl:with-param name="sensenode" select="$headsense" />
						<xsl:with-param name="method" select="$method" />
					</xsl:call-template>
				</xsl:variable>

				<!-- Value -->
				<xsl:if test='$debug = true()'>
					<xsl:message>
						<xsl:text>[D]   headid=</xsl:text>
						<xsl:value-of select="$headid" />
						<xsl:text>&#xa;</xsl:text>
					</xsl:message>
				</xsl:if>
				<xsl:value-of select="concat($headword,':',format-number($headid,'00'))" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

</xsl:transform>
