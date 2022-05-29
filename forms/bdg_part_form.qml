<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Symbology|Symbology3D|Fields|Forms" version="3.22.7-Białowieża">
  <renderer-3d layer="_xx_layer_id_placeholder_xx_" type="vector">
    <vector-layer-3d-tiling show-bounding-boxes="0" zoom-levels-count="3"/>
    <symbol type="polygon" material_type="phong">
      <data alt-clamping="relative" alt-binding="centroid" culling-mode="no-culling" invert-normals="0" height="0" add-back-faces="1" rendered-facade="3" extrusion-height="0"/>
      <material shininess="0" ambient="255,255,255,255" specular="255,255,255,255" diffuse="255,0,0,255">
      </material>
      <edges width="1" color="0,0,0,255" enabled="1"/>
    </symbol>
  </renderer-3d>
  <renderer-v2 symbollevels="0" forceraster="0" type="singleSymbol" referencescale="-1" enableorderby="0">
    <symbols>
      <symbol force_rhr="0" clip_to_extent="1" type="fill" name="0" alpha="1">
        <layer pass="0" locked="0" enabled="1" class="SimpleFill">
          <Option type="Map">
            <Option type="QString" name="color" value="255,0,0,255"/>
            <Option type="QString" name="style" value="solid"/>
          </Option>
        </layer>
      </symbol>
    </symbols>
  </renderer-v2>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <fieldConfiguration>
<!-- CityObject attributes -->  
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="termination_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_terrain" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="FilterExpression" type="QString" value="name = 'RelativeToTerrainType'"/>
            <Option name="Key" type="QString" value="value"/>
            <Option name="Layer" type="QString" value="_xx_placeholder_for_v_enumeration_value_xx_"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="relative_to_water" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" type="bool" value="false"/>
            <Option name="AllowNull" type="bool" value="true"/>
            <Option name="FilterExpression" type="QString" value="name = 'RelativeToWaterType'"/>
            <Option name="Key" type="QString" value="value"/>
            <Option name="Layer" type="QString" value="_xx_placeholder_for_v_enumeration_value_xx_"/>
            <Option name="NofColumns" type="int" value="1"/>
            <Option name="OrderByValue" type="bool" value="false"/>
            <Option name="UseCompleter" type="bool" value="false"/>
            <Option name="Value" type="QString" value="description"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_format" type="QString" value="dd-MM-yyyy HH:mm:ss"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
<!-- Up to here, all CityObject attributes -->
    <field name="class" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="class_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function" configurationFlags="None">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option type="bool" name="EmptyIsEmptyArray" value="false"/>
            <Option type="bool" name="EmptyIsNull" value="true"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="function_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage" configurationFlags="None">
      <editWidget type="List">
        <config>
          <Option type="Map">
            <Option type="bool" name="EmptyIsEmptyArray" value="false"/>
            <Option type="bool" name="EmptyIsNull" value="true"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="usage_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
<!-- Up to here, cfu attributes -->
    <field name="year_of_construction" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="yyyy"/>
            <Option name="field_format" type="QString" value="yyyy"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="year_of_demolition" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" type="bool" value="true"/>
            <Option name="calendar_popup" type="bool" value="true"/>
            <Option name="display_format" type="QString" value="yyyy"/>
            <Option name="field_format" type="QString" value="yyyy"/>
            <Option name="field_iso_format" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="roof_type_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="measured_height" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="measured_height_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storeys_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storeys_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_above_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_ag_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_below_ground" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="storey_heights_bg_unit" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
<!-- Added for parts -->
    <field name="building_parent_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="building_root_id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
          <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option>
        </config>
      </editWidget>
    </field>
<!-- Added for parts -->
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
<!-- End of CityObject attributes -->
    <alias index="14" name="Class" field="class"/>
    <alias index="15" name="Class codespace" field="class_codespace"/>
    <alias index="16" name="Function" field="function"/>
    <alias index="17" name="Function codespace" field="function_codespace"/>
    <alias index="18" name="Usage" field="usage"/>
    <alias index="19" name="Usage codespace" field="usage_codespace"/>
<!-- End of cfu attributes -->
    <alias index="20" name="Year of construction" field="year_of_construction"/>
    <alias index="21" name="Year of demolition" field="year_of_demolition"/>
    <alias index="22" name="Roof type" field="roof_type"/>
    <alias index="23" name="Roof type codespace" field="roof_type_codespace"/>
    <alias index="24" name="Height" field="measured_height"/>
    <alias index="25" name="UoM" field="measured_height_unit"/>
    <alias index="26" name="Storeys above ground" field="storeys_above_ground"/>
    <alias index="27" name="Storeys below ground" field="storeys_below_ground"/>
    <alias index="28" name="Storey height above ground&lt;&#47;b&gt;" field="storey_heights_above_ground"/>
    <alias index="29" name="UoM" field="storey_heights_ag_unit"/>
    <alias index="30" name="Storey height below ground" field="storey_heights_below_ground"/>
    <alias index="31" name="UoM" field="storey_heights_bg_unit"/>
<!-- Added for parts -->
    <alias index="101" name="Database parent ID" field="building_parent_id"/>
    <alias index="102" name="Database root ID" field="building_root_id"/>
<!-- Added for parts -->
  </aliases>
  <constraints>
    <constraint constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1" field="id"/>
<!-- End of CityObject attributes -->	
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="measured_height"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="measured_height_unit"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storeys_above_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storeys_below_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_above_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_ag_unit"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_below_ground"/>
    <constraint constraints="4" exp_strength="1" notnull_strength="0" unique_strength="0" field="storey_heights_bg_unit"/>
  </constraints>
  <constraintExpressions>
    <constraint desc="BOTH values must be either NULL or not NULL" field="measured_height" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)"/>
    <constraint desc="BOTH values must be either NULL or not NULL" field="measured_height_unit" exp="(&quot;measured_height&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;measured_height&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;measured_height_unit&quot; IS NULL)"/>
    <constraint desc="Number must be >= 0" field="storeys_above_ground" exp="(&quot;storeys_above_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_above_ground&quot; >= 0)"/>
    <constraint desc="Number must be >= 0" field="storeys_below_ground" exp="(&quot;storeys_below_ground&quot; IS NULL) OR&#xd;&#xa;(&quot;storeys_below_ground&quot; >= 0)"/>
    <constraint desc="BOTH values must be either NULL or not NULL" field="storey_heights_above_ground" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)"/>
    <constraint desc="BOTH values must be either NULL or not NULL" field="storey_heights_ag_unit" exp="(&quot;storey_heights_above_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_ag_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_above_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_ag_unit&quot; IS NULL)"/>
    <constraint desc="BOTH values must be either NULL or not NULL" field="storey_heights_below_ground" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)"/>
    <constraint desc="BOTH values must be either NULL or not NULL" field="storey_heights_bg_unit" exp="(&quot;storey_heights_below_ground&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa; &quot;storey_heights_bg_unit&quot;  IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;storey_heights_below_ground&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;storey_heights_bg_unit&quot; IS NULL)"/>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorContainer name="Main Info" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="id" showLabel="1" index="0"/>
<!-- Add here parent and root with parts -->
      <attributeEditorField name="building_parent_id" showLabel="1" index="101"/>
      <attributeEditorField name="building_root_id" showLabel="1" index="102"/>
<!--  -->	
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Relation to surface" visibilityExpression="" columnCount="1" showLabel="0" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
<!--     <attributeEditorContainer name="External references" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="_xx_external_reference_placeholder_id_xx_" nmRelationId="" showLabel="0" label="External References" forceSuppressFormPopup="0" relation="_xx_rel_eternaal_references_placeholder_id_xx_" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer> -->
    <attributeEditorContainer name="Generic Attributes" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="_xx_cityobject_genericattrib_placeholder_id_xx_" nmRelationId="" showLabel="0" label="Generic Attributes" forceSuppressFormPopup="0" relation="_xx_relation_generic_attributes_placeholder_id_xx_" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer>
<!--     <attributeEditorContainer name="Address(es)" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorRelation name="_xx_addresses_placeholder_id_xx_" nmRelationId="" showLabel="0" label="Generic Attributes" forceSuppressFormPopup="0" relation="_xx_relation_addresses_placeholder_id_xx_" relationWidgetTypeId="">
        <editor_configuration/>
      </attributeEditorRelation>
    </attributeEditorContainer> -->
<!-- just a separator -->
     <attributeEditorQmlElement showLabel="0" name="QmlWidget"></attributeEditorQmlElement>
<!--  -->
    <attributeEditorContainer name="Class" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="class" showLabel="1" index="14"/>
      <attributeEditorField name="class_codespace" showLabel="1" index="15"/>
    </attributeEditorContainer>

    <attributeEditorContainer name="Function" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="function" showLabel="1" index="16"/>
      <attributeEditorField name="function_codespace" showLabel="1" index="17"/>
    </attributeEditorContainer>

    <attributeEditorContainer name="Usage" visibilityExpression="" columnCount="1" showLabel="1" groupBox="0" visibilityExpressionEnabled="0">
      <attributeEditorField name="usage" showLabel="1" index="18"/>
      <attributeEditorField name="usage_codespace" showLabel="1" index="19"/>
    </attributeEditorContainer>	
<!-- just a separator -->
    <attributeEditorQmlElement showLabel="0" name="QmlWidget"></attributeEditorQmlElement>
<!--  -->
    <attributeEditorContainer name="Feature-specific attributes" visibilityExpression="" columnCount="2" showLabel="1" groupBox="1" visibilityExpressionEnabled="0">
      <attributeEditorField name="year_of_construction" showLabel="1" index="20"/>
      <attributeEditorField name="year_of_demolition" showLabel="1" index="21"/>
      <attributeEditorField name="storeys_above_ground" showLabel="1" index="26"/>
      <attributeEditorField name="storeys_below_ground" showLabel="1" index="27"/>
      <attributeEditorField name="measured_height" showLabel="1" index="24"/>
      <attributeEditorField name="measured_height_unit" showLabel="1" index="25"/>
      <attributeEditorField name="storey_heights_above_ground" showLabel="1" index="28"/>
      <attributeEditorField name="storey_heights_ag_unit" showLabel="1" index="29"/>
      <attributeEditorField name="storey_heights_below_ground" showLabel="1" index="30"/>
      <attributeEditorField name="storey_heights_bg_unit" showLabel="1" index="31"/>
      <attributeEditorField name="roof_type" showLabel="1" index="22"/>
      <attributeEditorField name="roof_type_codespace" showLabel="1" index="23"/>
    </attributeEditorContainer>

  </attributeEditorForm>
  <editable>
<!-- Default is editable, you can add only the non-editable ones   -->
    <field editable="0" name="id"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="creation_date"/>	
    <field editable="0" name="termination_date"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="lineage"/>
<!-- End of CityObject attributes -->
    <field editable="0" name="class_codespace"/>
    <field editable="0" name="function_codespace"/>
    <field editable="0" name="usage_codespace"/>
<!-- End of cfu attributes -->
    <field editable="0" name="roof_type_codespace"/>
<!-- Add here parent and root with parts -->
    <field editable="0" name="building_root_id"/>
    <field editable="0" name="building_parent_id"/>
<!--  -->
  </editable>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>2</layerGeometryType>
</qgis>
