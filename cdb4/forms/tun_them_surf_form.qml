<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|Symbology3D|Fields|Forms" version="3.22.7-Białowieża">
  <renderer-3d layer="_xx_layer_id_xx_" type="vector">
    <vector-layer-3d-tiling show-bounding-boxes="0" zoom-levels-count="3"/>
    <symbol type="polygon" material_type="phong">
      <data alt-clamping="relative" alt-binding="centroid" culling-mode="no-culling" invert-normals="0" height="0" add-back-faces="1" rendered-facade="3" extrusion-height="0"/>
<!-- Set the (diffuse) colour of the 3D geometries -->
       <material shininess="0" ambient="255,255,255,255" specular="255,255,255,255" diffuse="150,150,150,127">
      </material>
      <edges width="1" color="0,0,0,255" enabled="1"/>
    </symbol>
  </renderer-3d>
  <renderer-v2 symbollevels="0" forceraster="0" type="singleSymbol" referencescale="-1" enableorderby="0">
    <symbols>
      <symbol force_rhr="0" clip_to_extent="1" type="fill" name="0" alpha="1">
        <layer pass="0" locked="0" enabled="1" class="SimpleFill">
          <Option type="Map">
<!-- Set the colour of the 2D geometries -->
            <Option type="QString" name="color" value="150,150,150,127"/>
            <Option type="QString" name="style" value="solid"/>
          </Option>
        </layer>
      </symbol>
    </symbols>
  </renderer-v2>
  <fieldConfiguration>
<!-- cityobject attributes -->
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="termination_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_terrain">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_water">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="last_modification_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit"></editWidget>
    </field>
<!-- root/parent attributes -->
    <field configurationFlags="None" name="tunnel_id">
      <editWidget type="TextEdit"></editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0"  name="Database ID" field="id"/>
    <alias index="1"  name="GML ID" field="gmlid"/>
    <alias index="2"  name="GML codespace" field="gmlid_codespace"/>
    <alias index="3"  name="Name" field="name"/>
    <alias index="4"  name="Name codespace" field="name_codespace"/>
    <alias index="5"  name="Description" field="description"/>
    <alias index="6"  name="Creation date" field="creation_date"/>
    <alias index="7"  name="Termination date" field="termination_date"/>
    <alias index="8"  name="Relative to terrain" field="relative_to_terrain"/>
    <alias index="9"  name="Relative to water" field="relative_to_water"/>
    <alias index="10" name="Last modification" field="last_modification_date"/>
    <alias index="11" name="Updating person" field="updating_person"/>
    <alias index="12" name="Reason for update" field="reason_for_update"/>
    <alias index="13" name="Lineage" field="lineage"/>
<!-- parent/root attributes -->
    <alias index="101" name="Tunnel(Part) ID" field="tunnel_id"/>
  </aliases>
  <defaults></defaults>
  <constraints>
    <constraint constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1" field="id"/>
  </constraints>
  <constraintExpressions></constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
<!-- cityobject tabs with attributes -->  
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Main Info" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="id" showLabel="1" index="0"/>
<!-- Parent/root attributes BEGIN -->
      <attributeEditorField name="tunnel_id" showLabel="1" index="101"/>
<!-- Parent/root attributes END -->		  
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Database Info" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Relation to surface" columnCount="1" showLabel="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
<!--     <attributeEditorContainer name="External references" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="_xx_external_reference_placeholder_id_xx_" nmRelationId="" showLabel="0" label="External References" forceSuppressFormPopup="0" relation="_xx_rel_eternaal_references_placeholder_id_xx_" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer> -->
    <attributeEditorContainer visibilityExpression="" groupBox="0" name="Generic Attributes" columnCount="1" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorRelation relationWidgetTypeId="" label="Generic Attributes" name="_x_co_genatt_id_x_" relation="_x_rel_id_x_" showLabel="0" forceSuppressFormPopup="0" nmRelationId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="id"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="creation_date"/>	
    <field editable="0" name="termination_date"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="lineage"/>
<!-- parent and root attributes -->
    <field editable="0" name="tunnel_id"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
